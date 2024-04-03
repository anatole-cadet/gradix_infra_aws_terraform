/**
* Create security group 
*/
resource "aws_security_group" "security_group" {
    count = 3
    name = "${terraform.workspace}-GradixSG-${count.index}"
    vpc_id = var.vpc_id
    ingress {
        from_port = 22
        to_port = 22
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"
    }

    egress {
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "-1"
    }
}

/**
* We choose the security group for the public instances, and add inbound rule for access index.html
*/
locals {
  
value = [ for sg in aws_security_group.security_group: sg]
}
resource "aws_security_group_rule" "security_group_rule" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  security_group_id = local.value[1].id
  cidr_blocks = ["0.0.0.0/0"]
}

