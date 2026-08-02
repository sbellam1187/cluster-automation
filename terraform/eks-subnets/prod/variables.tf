variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID where subnets should be created"
  type        = string
}

variable "subnets" {
  description = "Subnets details"
  type = map(object({
    cidr_block        = string
    availability_zone = string
    type              = string
  }))
  default = {
    "kaas-prod-us-east-1a-ec2"    = { cidr_block = "10.218.160.0/23", availability_zone = "us-east-1a", type = "ec2" },
    "kaas-prod-us-east-1b-ec2"    = { cidr_block = "10.218.162.0/23", availability_zone = "us-east-1b", type = "ec2" },
    "kaas-prod-us-east-1c-ec2"    = { cidr_block = "10.218.164.0/23", availability_zone = "us-east-1c", type = "ec2" },
    "kaas-prod-us-east-1a-xeni"   = { cidr_block = "10.218.166.0/25", availability_zone = "us-east-1a", type = "xeni" },
    "kaas-prod-us-east-1b-xeni"   = { cidr_block = "10.218.166.128/25", availability_zone = "us-east-1b", type = "xeni" },
    "kaas-prod-us-east-1c-xeni"   = { cidr_block = "10.218.167.0/25", availability_zone = "us-east-1c", type = "xeni" },
    "kaas-prod-us-east-1a-public" = { cidr_block = "10.218.168.0/25", availability_zone = "us-east-1a", type = "public" },
    "kaas-prod-us-east-1b-public" = { cidr_block = "10.218.168.128/25", availability_zone = "us-east-1b", type = "public" },
    "kaas-prod-us-east-1c-public" = { cidr_block = "10.218.169.0/25", availability_zone = "us-east-1c", type = "public" },
    "kaas-prod-us-east-1a-pods"   = { cidr_block = "100.64.0.0/18", availability_zone = "us-east-1a", type = "pods" },
    "kaas-prod-us-east-1b-pods"   = { cidr_block = "100.64.64.0/18", availability_zone = "us-east-1b", type = "pods" },
    "kaas-prod-us-east-1c-pods"   = { cidr_block = "100.64.128.0/18", availability_zone = "us-east-1c", type = "pods" },
    # Add as many as needed...
  }
}

variable "public_rt_name" {
  description = "Name tag for the public route table"
  type        = string
  default     = null
}

variable "public_routes" {
  description = "Map of routes for the public route table."
  type = map(object({
    destination_cidr_block = string
    gateway_id             = optional(string)
    transit_gateway_id     = optional(string)
  }))
  default = {}
}
