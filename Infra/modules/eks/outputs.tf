output "eks_cluster_arn" {
  description = "The ARN of the EKS Cluster"
  value = aws_eks_cluster.eks.arn
}
output "eks_nodegroup_arn" {
  description = "The ARN of the EKS Node group"
  value = aws_eks_node_group.node-grp.arn
}
# output "eks_service_nodegroup_arn" {
#   value = aws_eks_node_group.service_node-grp.arn
#   description = "The ARN of the EKS service node group"
# }
output "eks_jenkins_role_name" {
  value = aws_iam_role.jenkins_role.name
  description = "Name of the Jenkins role that has EKS entrypoint"
}