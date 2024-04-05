resource "aws_security_group" "security_group_private" {
    name = "${terraform.workspace}-GradixSG-0"
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
    tags = {
        Name = "${terraform.workspace}-GradixSG-0"
    }
}

resource "aws_security_group" "security_group_public" {
    name = "${terraform.workspace}-GradixSG-1"
    vpc_id = var.vpc_id
    ingress {
        from_port = 22
        to_port = 22
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"
    }
    ingress {
        from_port = 80
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"
    }
    
    egress {
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "-1"
    }
    tags = {
        Name = "${terraform.workspace}-GradixSG-1"
    }
}
