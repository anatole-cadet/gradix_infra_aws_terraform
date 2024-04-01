# output "subnet_id" {
#   value = aws_subnet.subnet.id
# }

output "number_subnet_created" {
  value = var.number_subnet
}


output "subnet_output" {
  value = [ for subnet in aws_subnet.subnet : subnet]
}



