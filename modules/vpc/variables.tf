
variable "vpc_cidr_block" {
  description = "The cidr block of the vpc"
}

variable "vpc_tag_name" {
  description = "This is the tag name of the vpc"
  type = string
  nullable = false
}