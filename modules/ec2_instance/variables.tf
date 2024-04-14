variable "ami" {
  
}

variable "instance_type" {
  
}

variable "number_ec2_instance" {
  description = "The number of instance to create"
  type = number
  nullable = false
  validation {
    condition = var.number_ec2_instance > 1 && var.number_ec2_instance < 6
    error_message = "The number of instance to create must be between 2 and 5."
  }
}

variable "subnet_list" {
  
}

variable "security_group_list" {
  
}

variable "environment" {
  
}