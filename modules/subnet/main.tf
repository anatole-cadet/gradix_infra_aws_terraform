
data "aws_availability_zones" "availability_zones_gradix" {
  state    = "available"
  provider = aws
}

resource "aws_subnet" "subnet" {
  count             = var.number_subnet
  cidr_block        = cidrsubnet(var.cidr_block_vpc, 8, count.index + 1)
  availability_zone = data.aws_availability_zones.availability_zones_gradix.names[count.index]
  vpc_id            = var.vpc_id
  tags = {
    Name = "${var.environment}-GradixSubnet-${count.index}"
  }
}