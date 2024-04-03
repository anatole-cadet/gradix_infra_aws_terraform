output "security_group_list_output" {
  value = [ for sg in aws_security_group.security_group: sg]
}