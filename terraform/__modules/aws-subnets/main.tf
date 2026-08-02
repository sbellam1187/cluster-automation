resource "aws_subnet" "this" {
  for_each          = var.subnets
  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    "Name" = each.key
    "Type" = each.value.type
  }
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  tags = {
    Name = var.public_rt_name
  }
}

# Each route managed independently so a single change doesn't affect all routes
resource "aws_route" "public" {
  for_each = var.public_routes

  route_table_id         = aws_route_table.public.id
  destination_cidr_block = each.value.destination_cidr_block
  gateway_id             = try(each.value.gateway_id, null)
  transit_gateway_id     = try(each.value.transit_gateway_id, null)
}

# Associate public subnets with the managed route table
resource "aws_route_table_association" "public" {
  for_each       = { for name, subnet in var.subnets : name => subnet if subnet.type == "public" }
  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public.id
}

# Data sources
data "aws_region" "current" {}

data "aws_eks_cluster" "allowed" {
  for_each = var.allowed_cluster_names
  name     = each.value
}

# Security group (Interface endpoints only)
resource "aws_security_group" "vpc_endpoints" {
  name        = "vpc-endpoints-sg"
  description = "Allow TLS traffic from inside the VPC to Interface Endpoints"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = data.aws_eks_cluster.allowed
    content {
      description     = "TLS from allowed EKS cluster security groups"
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      security_groups = [ingress.value.vpc_config[0].cluster_security_group_id]
    }
  }

  tags = {
    Name = "vpc-endpoints-sg"
  }
}

# Interface endpoints (e.g. sts, eks-auth)
resource "aws_vpc_endpoint" "interface" {
  for_each = var.interface_endpoint_services

  vpc_id              = var.vpc_id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  subnet_ids          = [for name, subnet in aws_subnet.this : subnet.id if var.subnets[name].type == "ec2"]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    "Name" = each.key
  }
}
