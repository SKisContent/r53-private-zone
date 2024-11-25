#!/bin/bash

set -e

# Set these variables
REGIONS="us-east-1 us-west-2"
instance_type="t3.nano"

# You should not need to change the following
OPTIONS=$*
TF_VAR_expiration_date=$(date -v+1d -u +"%Y-%m-%dT%H:%M:%SZ" )
export TF_VAR_expiration_date
TF_VAR_instance_type="$instance_type"
export TF_VAR_instance_type

for region in $REGIONS 
do
    # Get all AZs in a region
    ALL_AZS=$(aws ec2 describe-availability-zones --region "${region}" | jq -r '.[][].ZoneName')

    # Get all AZs that support the instance type
    SUPPORTED_AZS=$(aws ec2 describe-instance-type-offerings \
        --location-type availability-zone \
        --filters Name=instance-type,Values="${instance_type}" \
        --region "${region}" \
        | jq -r '.[][].Location')

    # Annotate which AZs do not support the instance type
    for AZ in $ALL_AZS ; do
        if echo "$SUPPORTED_AZS" | grep -q "$AZ" ; then
            echo "Using AZ $AZ"
            TF_VAR_instance_az="$AZ"
            export TF_VAR_instance_az
            break
        fi
    done

    ws_exists=$(terraform workspace list|grep "$region")
    if [ "$ws_exists" = "" ]; then
        terraform workspace new "$region"
    fi
    terraform workspace select "$region"
    echo "terraform $OPTIONS"
    TF_VAR_aws_region="$region" terraform "$OPTIONS"
done
