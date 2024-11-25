variable "aws_region" {
  type        = string
  description = "The regions in which to create the infra"
}

variable "instance_type" {
  type        = string
  description = "The instance type that should be created"
}

variable "instance_az" {
  type        = string
  description = "An availability zone that contains the instance type"
}

variable "default_tags" {
  default = null
}

variable "expiration_date" {
  type        = string
  description = "A timestamp after which the resources in this configuration may be destroyed"
}
