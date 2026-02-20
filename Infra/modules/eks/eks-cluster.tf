resource "aws_eks_cluster" "eks" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.master.arn

  vpc_config {
    subnet_ids = concat(var.eks_private_subnet_ids, var.eks_public_subnet_ids)
    endpoint_private_access = true
    endpoint_public_access  = var.eks_public_access
  }
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
  tags = merge(var.tags, {
    Name = var.eks_cluster_name
  })
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
  ]

}

# resource "aws_eks_access_entry" "jenkins" {
#   cluster_name      = aws_eks_cluster.eks.name
#   principal_arn     = aws_iam_role.jenkins_role.arn
#   kubernetes_groups = ["group-1", "group-2"]
#   type              = "STANDARD"
# }