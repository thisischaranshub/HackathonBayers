variable "tags" {
  description = "Tags to apply to VPC resources"
  type        = map(string)
}

variable "deduced_name" {
    description = "Deduced name for all resources based on project, environment and other factors"
    type = string
}

variable "ami_name_map" {
    description = "AMI name map for blue and green ASGs"
    type = object({
      blue = string
      green = string
    })
}

variable "placement_group_strategy" {
    description = "EC2 placement group strategy"
    type = string
}

variable "keypair_file_path" {
    description = "keypair file path"
    type = string
    # Add validation to validate the variable being filepath
}

variable "vpc_id" {
    description = "VPC ID"
    type = string
}

variable "alb_subnet_ids" {
    description = "Subnet IDs for ALB"
    type = list
}

variable "asg_subnet_ids" {
    description = "Subnet IDs for ASG"
    type = list
}

variable "ec2_security_group_rules" {
    description = "Ports and allowed sources for EC2 SG"
    type = map(object({
        ports = string
        ip_protocol = string
        type = string  # SGID or CIDR
        source = string
    }))
    # example :
    # {
    #     "Allow SSH from DB SG" = {
    #         ports = "443"
    #         protocol = "tcp"
    #         type = "SG"
    #         source = "sg-ahdhgbd"
    #     },
    #     "Allow HTTPS ports from ALB" = {
    #         ports = "8085-8090"
    #         protocol = "tcp"
    #         type = "SG"
    #         source = "sg-ahdhgbd"
    #     }
    # }
    # Add validations for port and type fields
}

variable "alb_security_group_rules" {
    description = "Ports and allowed sources for EC2 SG"
    type = map(object({
        ports = string
        ip_protocol = string
        type = string  # SGID or CIDR
        source = string
    }))
}

variable "ec2_additional_block_device_mappings" {
  description = "EC2 instances additional block device mappings"
  type = map(object({
    volume_type = string
    volume_size = string
    encrypted   = bool
  }))
    # example :
    # {
    #     "/dev/sdc" = {
    #         volume_type = "gp2"
    #         volume_size = "20"
    #         encrypted   = true
    #     }
    # }
}

variable "ec2_capacity_reservation_preference" {
    description = "EC2 capacity reservation preference"
    type = string
}

variable "ec2_cpu_credits" {
    description = "EC2 cpu credits"
    type = string
}

variable "ec2_market" {
    description = "EC2 market"
    type = string
}

variable "ec2_instance_type" {
    description = "EC2 Instance type"
    type = string
}

variable "active_asg" {
    description = "Active ASG (Either blue or green)"
    type = string
}

variable "asg_scale" {
    description = "Min, Max and Desired instances for green ASG"
    type = object({
      min = number
      max = number
      desired_capacity = number
    })
    # example :
    # {
    #     {
    #         minimum = 2
    #         maximum = 2
    #         desired_capacity = 2
    #     }
    # }
}