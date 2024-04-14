output "list_instance_to_register_output" {
  /* we ignore the first instance terminated by 0, it is a private instance */
  value = slice([for ec2 in aws_instance.instance : ec2], 1, length([for ec2 in aws_instance.instance : ec2]))
}

