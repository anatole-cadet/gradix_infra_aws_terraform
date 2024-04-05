# output "security_group_list_output" {
#   value = [ for sg in aws_security_group.security_group: sg]
# }

output "security_group_id_output" {
  value = [aws_security_group.security_group_private.id, aws_security_group.security_group_public.id]
}