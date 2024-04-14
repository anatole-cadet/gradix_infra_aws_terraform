
resource "aws_eip" "elastic_ip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = var.subnet_id
  tags = {
    Name = "${var.environment}-GradixNatGateWay"
  }
}