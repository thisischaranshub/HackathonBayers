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
  source = "../../../../../modules/eks"
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

dependencies {
  paths = ["../vpc"]
}

locals {
  region = basename(dirname(get_terragrunt_dir()))
  project     = "poc-2"
  environment = basename(dirname(dirname(get_terragrunt_dir())))
  name        = "${local.project}-${local.environment}"
  business_divsion = "poc-2-devops"
  eks_account_id = "768132174891"
  eks_cluster_name = "${local.name}-cluster"
  eks_nodegroup_name = "${local.name}-eks-nodegroup"
  eks_nodegroup_keypair_name = "${local.name}-eks-keypair"
  common_tags = {
    business_divsion = local.business_divsion
    environment      = local.environment
    project          = local.project
  }
}

# Pass input variables to the Terraform module.
inputs = {
  region                               = local.region
  eks_cluster_name                     = local.eks_cluster_name
  eks_region                           = local.region
  eks_account_id                       = local.eks_account_id
  eks_vpc_id                           = dependency.vpc.outputs.vpc_id
  eks_vpc_cidr                         = "10.51.0.0/18"
  eks_public_access                    = true
  eks_private_subnet_ids               = values(dependency.vpc.outputs.private_subnet_ids)
  eks_public_subnet_ids                = values(dependency.vpc.outputs.public_subnet_ids)
  eks_node_group_name                  = local.eks_nodegroup_name
  eks_nodegroup_ami_type               = "AL2023_x86_64_STANDARD"
  eks_nodegroup_capacity_type          = "ON_DEMAND"
  eks_nodegroup_instance_types         = ["t3.large"]
  eks_nodegroup_disk_size              = 200
  eks_nodes_keypair_name               = local.eks_nodegroup_keypair_name
  eks_nodes_keypair_path               = "./poc-2-dev-key.pub"
  eks_nodegroup_env_tomap              = "poc-2-dev"
  eks_nodegroup_desired_size           = 1
  eks_nodegroup_max_size               = 1
  eks_nodegroup_min_size               = 1
  ecr_repo_names                       = ["nodejs-app"]
  tags                                 = local.common_tags
}
