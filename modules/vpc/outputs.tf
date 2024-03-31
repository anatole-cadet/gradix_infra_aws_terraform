output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_tags" {
  value = aws_vpc.vpc.tags_all
}