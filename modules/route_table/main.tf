

resource "aws_route_table" "route_table" {
    count = var.number_route_table
    vpc_id = var.vpc_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = var.gateway_id
    }

    tags = {
        Name = "${terraform.workspace}-GradixRouteTable-${count.index}"
    }
}

