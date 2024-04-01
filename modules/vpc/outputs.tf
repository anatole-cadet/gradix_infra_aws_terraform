output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_tags" {
  value = aws_vpc.vpc.tags_all
}


output "vpc_cidr_block_output" {
  value = aws_vpc.vpc.cidr_block
}