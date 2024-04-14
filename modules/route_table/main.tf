
resource "aws_route_table" "route_table_private" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.gateway_id
  }
  tags = {
    Name = "${var.environment}-GradixRouteTable-0"
  }
}


resource "aws_route_table" "route_table_public" {
  vpc_id = var.vpc_id
  route {
    cidr_block     = var.subnet_list[1].cidr_block
    nat_gateway_id = var.nat_gateway_id

  }
  tags = {
    Name = "${var.environment}-GradixRouteTable-1"
  }
}

