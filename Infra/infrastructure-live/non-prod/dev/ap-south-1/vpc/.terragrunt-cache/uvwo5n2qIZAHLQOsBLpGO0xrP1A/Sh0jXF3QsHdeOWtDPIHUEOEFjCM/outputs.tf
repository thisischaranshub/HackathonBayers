output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Map of public subnets"
  value = {
    for key, subnet in aws_subnet.this :
    key => subnet.id
    if strcontains(key, "public")
  }
}

output "private_subnet_ids" {
  description = "Map of public subnets"
  value = {
    for key, subnet in aws_subnet.this :
    key => subnet.id
    if strcontains(key, "private")
  }
}