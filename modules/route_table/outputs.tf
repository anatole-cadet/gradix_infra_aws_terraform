# output "route_table_output" { 
#     value = {
#      route_table =   aws_route_table.route_table
# }

# }
output "route_table_output" { 
    value = [ for route_table in aws_route_table.route_table : route_table ]
}

# output "route_output" {
#   value = aws_route.route.id
# }

# output "ipv4_subnet_output" {
#   value = [ for ip in var.ipv4_subnet : ip]
# }
# output "number_route_table" {
#   value = "${module.subnet.number_subnet_created}"
# }