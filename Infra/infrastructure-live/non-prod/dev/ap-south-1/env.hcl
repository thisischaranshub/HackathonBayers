# All environment variables go here
locals {
    vpc_cidr = "10.51.0.0/18"
    subnets = [
    {
      az      = "ap-south-1a"
      cidr    = "10.51.1.0/24"
      private = false
    },
    {
      az      = "ap-south-1a"
      cidr    = "10.51.2.0/24"
      private = true
    },
    {
      az      = "ap-south-1b"
      cidr    = "10.51.3.0/24"
      private = false
    },
    {
      az      = "ap-south-1b"
      cidr    = "10.51.4.0/24"
      private = true
    },
    {
      az      = "ap-south-1c"
      cidr    = "10.51.5.0/24"
      private = false
    },
    {
      az      = "ap-south-1c"
      cidr    = "10.51.6.0/24"
      private = true
    },
  ]
}