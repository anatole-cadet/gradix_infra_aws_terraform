output "nat_gateway_id_output" {
  value = aws_nat_gateway.nat_gateway.id
}

output "subnet_of_nat_gateway_output" {
  value = var.subnet_id
}