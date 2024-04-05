
output "security_group_id_output" {
  value = [aws_security_group.security_group_private.id, aws_security_group.security_group_public.id]
}