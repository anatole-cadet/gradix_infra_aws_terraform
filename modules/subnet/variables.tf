variable "number_subnet" {
  description = "The number of subnet to create"
  type = number
  nullable = false
  validation {
    condition = var.number_subnet < 7
    error_message = "The number of subnet must be smaller than 7"
  }
}

variable "vpc_id" {
  description = "The ID of the vpc"
}

variable "cidr_block_vpc" {
  description = "The cidr of the VPC"
}

variable "environment" {
  
}