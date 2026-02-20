# All backend, provider settings go here, everything will be merged to subsequent child terragrunt stacks
locals {
  region = basename(dirname(get_terragrunt_dir()))
  backend_region = "ap-south-1"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "poc-2-tp-terraform-state-bucket"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.backend_region
    dynamodb_table = "poc-2-tp-terraform-locks-dev"
    encrypt        = true
  }
}

generate "providers" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28.0"
    }
  }
}

provider "aws" {
  region = "${local.region}"
}

EOF
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "s3" {}
}
EOF
}