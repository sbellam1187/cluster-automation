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
  default = {}
}

variable "public_rt_name" {
  description = "Name tag for the public route table."
  type        = string
  default     = null
}

variable "public_routes" {
  description = "Map of routes to manage in the public route table."
  type = map(object({
    destination_cidr_block = string
    gateway_id             = optional(string)
    transit_gateway_id     = optional(string)
  }))
  default = {}
}

variable "allowed_cluster_names" {
  description = "EKS cluster names allowed to access Interface VPC endpoints. Each cluster name is resolved to its cluster security group ID."
  type        = set(string)
  default     = []
}


variable "interface_endpoint_services" {
  description = "Short AWS service names for Interface endpoints (e.g. [\"sts\", \"sqs\", \"ecr.api\"]). The module builds the full service name from the current region and creates a shared security group."
  type        = set(string)
  default     = []
}
