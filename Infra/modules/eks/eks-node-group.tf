resource "aws_key_pair" "eks-nodes-key-pair" {
  key_name     = var.eks_nodes_keypair_name
  public_key = file(var.eks_nodes_keypair_path)
}

resource "aws_security_group" "eks_sg" {
  name        = "allow_tls"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.eks_vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.eks_vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_eks_node_group" "node-grp" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.eks_node_group_name
  node_role_arn   = aws_iam_role.worker.arn
  subnet_ids      = var.eks_private_subnet_ids
  ami_type        = var.eks_nodegroup_ami_type
  capacity_type   = var.eks_nodegroup_capacity_type
  disk_size       = var.eks_nodegroup_disk_size
  instance_types  = var.eks_nodegroup_instance_types

  remote_access {
    ec2_ssh_key               = var.eks_nodes_keypair_name
    source_security_group_ids = [aws_security_group.eks_sg.id]
  }

  labels = tomap({ env = var.eks_nodegroup_env_tomap })

  #tags = {
  #  Name = "EKS_Node"
  #}

  scaling_config {
    desired_size = var.eks_nodegroup_desired_size
    max_size     = var.eks_nodegroup_max_size
    min_size     = var.eks_nodegroup_min_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

# # Service node group

# resource "aws_eks_node_group" "service_node-grp" {
#   cluster_name    = aws_eks_cluster.eks.name
#   node_group_name = var.eks_service_node_group_name
#   node_role_arn   = aws_iam_role.worker.arn
#   subnet_ids      = var.eks_private_subnet_ids
#   ami_type        = var.eks_nodegroup_ami_type
#   capacity_type   = var.eks_nodegroup_capacity_type
#   disk_size       = var.eks_service_nodegroup_disk_size
#   instance_types  = var.eks_service_nodegroup_instance_types

#   remote_access {
#     ec2_ssh_key               = var.eks_nodes_keypair_name
#     source_security_group_ids = var.eks_nodegroup_sg_ids
#   }

#   labels = tomap({ env = var.eks_nodegroup_env_tomap })

#   #tags = {
#   #  Name = "EKS_Node"
#   #}

#   scaling_config {
#     desired_size = var.eks_service_nodegroup_scaling_size
#     max_size     = var.eks_service_nodegroup_scaling_size
#     min_size     = var.eks_service_nodegroup_scaling_size
#   }

#   update_config {
#     max_unavailable = 1
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
#   ]
# }