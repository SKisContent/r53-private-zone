locals {
  expire_by = timeadd(timestamp(), "24h")
  default_tags = {
    git_repo        = "skiscontent/r53-private-zone"
    git_branch      = "main"
    purpose         = "This is a demo of multiple private zones"
    expiration_date = var.expiration_date
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = merge(local.default_tags)
  }
}
