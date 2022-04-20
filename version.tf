terraform {
  required_version = ">= 0.15"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72"
    }
  }

  # backend "s3" {
  #   key = "terraform-aws/terraform.tfstate"
  # }
}
