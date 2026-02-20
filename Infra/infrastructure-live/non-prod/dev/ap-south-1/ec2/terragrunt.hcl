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
  source = "../../../../../modules/ec2"
}

# Define dependency on other Terragrunt modules for remote state access
dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "vpc-mock"
    private_subnet_ids = {"1": "private-subnet-1", "2": "private-subnet-2"}
    public_subnet_ids = {"1": "public-subnet-1", "2": "public-subnet-2"}
  }
}

# Define dependent modules for ordering (The order in which terragrunt applies the modules)
dependencies {
  paths = ["../vpc"]
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
  region = local.region
  deduced_name  = local.name
  tags = local.common_tags
  placement_group_strategy = "cluster"
  ami_name_map  = {
    blue = "poc-2-dev-ami-v1"
    green = "poc-2-dev-ami-v2"
  }
  keypair_file_path = "./poc-2-dev-key.pub"
  vpc_id = dependency.vpc.outputs.vpc_id
  asg_subnet_ids = values(dependency.vpc.outputs.private_subnet_ids)
  alb_subnet_ids = values(dependency.vpc.outputs.public_subnet_ids)
  ec2_security_group_rules = {
    "Allow HTTP from ALB source" = {
        ports = "80"
        ip_protocol = "tcp"
        type = "CIDR"
        source = "10.51.0.0/18"
    }
    "Allow HTTPS from ALB source" = {
        ports = "443"
        ip_protocol = "tcp"
        type = "CIDR"
        source = "10.51.0.0/18"
    },
    "Allow custom ports from VPC" = {
        ports = "8085-8090"
        ip_protocol = "tcp"
        type = "CIDR"
        source = "10.51.0.0/18"
    }
  }
  alb_security_group_rules = {
    "Allow HTTP from anywhere" = {
        ports = "80"
        ip_protocol = "tcp"
        type = "CIDR"
        source = "0.0.0.0/0"
    }
  }
  ec2_additional_block_device_mappings = {
    "/dev/sdc" = {
        volume_type = "gp2"
        volume_size = "20"
        encrypted   = true
    }
  }
  ec2_capacity_reservation_preference = "open"
  ec2_cpu_credits = "standard"
  ec2_market = "spot"
  ec2_instance_type = "t3.micro"
  active_asg = "green"
  asg_scale = {
      min = 2
      max = 2
      desired_capacity = 2
  }
}
