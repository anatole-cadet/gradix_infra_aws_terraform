

output "route_table_id_output" {
  value = [aws_route_table.route_table_private.id, aws_route_table.route_table_public.id]
}

