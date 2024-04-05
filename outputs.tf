output "subnet_output" {
  value = module.subnet_module.subnet_output
}
output "route_table_output" {
  value = module.route_table.route_table_id_output #module.route_table.route_table_output
}

output "security_group_id" {
  value = module.security_group_module.security_group_id_output
}

output "length_security_group_id" {
  value = length(module.security_group_module.security_group_id_output)
}