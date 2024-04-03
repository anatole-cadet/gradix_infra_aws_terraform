# Creating the VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${terraform.workspace}-Gradix-VPC"
  }
}