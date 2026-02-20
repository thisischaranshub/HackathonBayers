variable "tags" {
  description = "Tags to apply to VPC resources"
  type        = map(string)
}

variable "deduced_name" {
    description = "Deduced name for all resources based on project, environment and other factors"
    type = string

    validation {
      condition = !can(regex("[+=*]+", var.deduced_name))
      error_message = "Name for any resource cannot contain one of [+=_]"
    }
}

variable "vpc_cidr" {
    description = "VPC CIDR range"
    type = string
}

variable "subnets" {
    description = "All necessary subnets"
    type = list(object({
        az = string
        cidr = string
        private = bool
    }))
}

variable "azs" {
    description = "Availability zones"
    type = list(string)
}

variable "nat_gw_routes" {
    description = "Destination CIDR of all routes that go through the default NAT GW"
    type = list(string)
}

variable "igw_routes" {
    description = "Destination CIDR of all routes that go through the default Internet GW"
    type = list(string)
}