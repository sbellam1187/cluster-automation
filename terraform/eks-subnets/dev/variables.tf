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
    "kaas-nonprod-us-east-1a-ec2-01"    = { cidr_block = "10.218.64.0/23", availability_zone = "us-east-1a", type = "ec2" },
    "kaas-nonprod-us-east-1b-ec2-02"    = { cidr_block = "10.218.66.0/23", availability_zone = "us-east-1b", type = "ec2" },
    "kaas-nonprod-us-east-1c-ec2-03"    = { cidr_block = "10.218.68.0/23", availability_zone = "us-east-1c", type = "ec2" },
    "kaas-nonprod-us-east-1a-xeni-01"   = { cidr_block = "10.218.70.0/25", availability_zone = "us-east-1a", type = "xeni" },
    "kaas-nonprod-us-east-1b-xeni-02"   = { cidr_block = "10.218.70.128/25", availability_zone = "us-east-1b", type = "xeni" },
    "kaas-nonprod-us-east-1c-xeni-03"   = { cidr_block = "10.218.71.0/25", availability_zone = "us-east-1c", type = "xeni" },
    "kaas-nonprod-us-east-1a-public-01" = { cidr_block = "10.218.72.0/25", availability_zone = "us-east-1a", type = "public" },
    "kaas-nonprod-us-east-1b-public-02" = { cidr_block = "10.218.72.128/25", availability_zone = "us-east-1b", type = "public" },
    "kaas-nonprod-us-east-1c-public-03" = { cidr_block = "10.218.73.0/25", availability_zone = "us-east-1c", type = "public" },
    "kaas-nonprod-us-east-1a-pods-01"   = { cidr_block = "100.64.0.0/18", availability_zone = "us-east-1a", type = "pods" },
    "kaas-nonprod-us-east-1b-pods-02"   = { cidr_block = "100.64.64.0/18", availability_zone = "us-east-1b", type = "pods" },
    "kaas-nonprod-us-east-1c-pods-03"   = { cidr_block = "100.64.128.0/18", availability_zone = "us-east-1c", type = "pods" },
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
