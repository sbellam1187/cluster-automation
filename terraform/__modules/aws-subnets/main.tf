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
