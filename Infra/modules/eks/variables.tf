variable "tags" {
  description = "Tags to apply to S3 resources"
  type        = map(string)
}
variable "eks_private_subnet_ids" {
  description = "Subnet IDs for EKS"
  type        = list(string)
}
variable "eks_public_subnet_ids" {
  description = "Subnet IDs for EKS"
  type        = list(string)
}
variable "eks_cluster_name" {
  description = "The name of the cluster"
  type = string
}
variable "eks_region" {
  description = "EKS cluster region"
  type = string
}
variable "eks_account_id" {
  description = "AWS account region"
  type = string
}
variable "eks_public_access" {
  description = "Whether to allow EKS public access or not"
  type = bool
}
variable "eks_node_group_name" {
  description = "Name of the node group."
  type = string
}
# variable "eks_service_node_group_name" {
#   description = "Name of the service node group."
#   type = string
# }
variable "eks_nodegroup_ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group."
  type = string
}
variable "eks_nodegroup_capacity_type" {
  description = "Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT"
  type = string
}
variable "eks_nodegroup_disk_size" {
  description = "Disk size in GiB for worker nodes"
  type = number
}
# variable "eks_service_nodegroup_disk_size" {
#   description = "Disk size in GiB"
#   type = number
# }
variable "eks_nodegroup_instance_types" {
  description = "Set of instance types associated with the EKS Node Group."
  type = list(string)
}
# variable "eks_service_nodegroup_instance_types" {
#   description = "Set of instance types associated with the EKS Node Group."
#   type = list(string)
# }
variable "eks_nodes_keypair_name" {
  description = "EC2 Key Pair name that provides access for SSH communication with the worker nodes in the EKS Node Group."
  type = string
}
variable "eks_nodes_keypair_path" {
  description = "EC2 Key Pair path that provides access for SSH communication with the worker nodes in the EKS Node Group."
  type = string
}
# variable "eks_nodegroup_sg_ids" {
#   description = " Set of EC2 Security Group IDs to allow SSH access (port 22) from on the worker nodes"
#   type = list(string)
# }
variable "eks_nodegroup_env_tomap" {
  description = " Key-value map of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument"
  type = string
}
variable "eks_nodegroup_desired_size" {
  description = " Desired number of worker nodes"
  type = number
}
variable "eks_nodegroup_max_size" {
  description = "Maximum number of worker nodes"
  type = number
}
variable "eks_nodegroup_min_size" {
  description = "Minimum number of worker nodes."
  type = number
}
# variable "eks_service_nodegroup_scaling_size" {
#   description = " Desired number of worker nodes"
#   type = number
# }

variable "eks_vpc_id" {
  description = "VPC ID for EKS"
  type = string
}

variable "eks_vpc_cidr" {
  description = "VPC CIDR for EKS VPC"
  type = string
}

variable "ecr_repo_names" {
  description = "List of the ECR repository names that you want to create"
  type = list(string)
}