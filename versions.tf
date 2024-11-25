terraform {
  backend "local" {}
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    external = {
      source = "hashicorp/external"
    }
    null = {
      source = "hashicorp/null"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}
