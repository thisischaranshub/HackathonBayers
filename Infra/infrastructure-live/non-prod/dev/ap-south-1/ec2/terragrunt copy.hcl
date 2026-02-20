# Include common configurations from the parent folders (e.g., backend settings, providers).
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Include common environment variables
include "env" {
  path = find_in_parent_folders("env.hcl")
}

# Specify the source of the Terraform module to deploy.
# This example uses a Git source with a specific version ref.
terraform{
  source = "../../../../../modules/ec2"
}

# Define dependencies on other Terragrunt modules.
# Terragrunt ensures these are applied before the current module.
dependencies "vpc" {
  paths = ["../vpc"]
}

locals {
  region = try(
    include.env.locals.aws_region,
    "ap-south-1"
  )
  environment = try(
    include.env.locals.env,
    "dev"
  )
  name        = "${local.project}-${local.environment}"
  business_divsion = "poc-2-devops"
  common_tags = {
    business_divsion = local.business_divsion
    environment      = local.environment
    project          = local.project
  }
}

# Pass input variables to the Terraform module.
# These values can be environment-specific.
inputs = {
  region = local.region
  deduced_name  = local.name
  tags = local.common_tags
  placement_group_strategy = var.placement_group_strategy
  ami_name_map = var.ami_name_map
  keypair_file_path = var.keypair_file_path
  vpc_id = dependency.vpc.outputs.vpc_id
  asg_subnet_ids = values(dependency.vpc.outputs.private_subnet_ids)
  alb_subnet_ids = values(dependency.vpc.outputs.public_subnet_ids)
  ec2_security_group_rules = var.ec2_security_group_rules
  alb_security_group_rules = var.alb_security_group_rules
  ec2_additional_block_device_mappings = var.ec2_additional_block_device_mappings
  ec2_capacity_reservation_preference = var.ec2_capacity_reservation_preference
  ec2_cpu_credits = var.ec2_cpu_credits
  ec2_market = var.ec2_market
  ec2_instance_type = var.ec2_instance_type
  active_asg = var.active_asg
  asg_scale = var.asg_scale
}
