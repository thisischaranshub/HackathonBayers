# Include common configurations from the parent folders (e.g., backend settings, providers).
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Include common environment variables
include "env" {
  path = find_in_parent_folders("env.hcl")
  expose = true
}

# Source of the Terraform module to deploy.
terraform{
  source = "../../../../../modules/vpc"
}

locals {
  region = basename(dirname(get_terragrunt_dir()))
  project     = "poc-2"
  environment = basename(dirname(dirname(get_terragrunt_dir())))
  name        = "${local.project}-${local.environment}"
  business_divsion = "poc-2-devops"
  common_tags = {
    business_divsion = local.business_divsion
    environment      = local.environment
    project          = local.project
  }
}

# Pass input variables to the Terraform module.
inputs = {
  region        = local.region
  deduced_name  = local.name
  vpc_cidr      = try(include.env.locals.vpc_cidr, "10.51.0.0/18")
  azs           = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  subnets       = try(include.env.locals.subnets,[
    {
      az      = "ap-south-1a"
      cidr    = "10.51.1.0/24"
      private = false
    },
    {
      az      = "ap-south-1a"
      cidr    = "10.51.2.0/24"
      private = true
    },
    {
      az      = "ap-south-1b"
      cidr    = "10.51.3.0/24"
      private = false
    },
    {
      az      = "ap-south-1b"
      cidr    = "10.51.4.0/24"
      private = true
    },
    {
      az      = "ap-south-1c"
      cidr    = "10.51.5.0/24"
      private = false
    },
    {
      az      = "ap-south-1c"
      cidr    = "10.51.6.0/24"
      private = true
    },
  ])
  nat_gw_routes = ["0.0.0.0/0"]
  igw_routes    = ["0.0.0.0/0"]
  tags          = local.common_tags
}
