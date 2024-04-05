
/**
* The NatGateway is created on the first subnet
* So this subnet is the public subnet.
* This first subnet is associate to the first route table
*Then, by adding route to the routes table, we identified the public one and the private.
*/
# resource "aws_route_table" "route_table" {
#     count = var.number_route_table
#     vpc_id = var.vpc_id
#     route {
#         cidr_block = count.index == 0 ? "0.0.0.0/0":var.subnet_list[1].cidr_block
#         gateway_id = count.index == 0 ? var.gateway_id: var.nat_gateway_id
#     }
#     tags = {
#         Name = "${terraform.workspace}-GradixRouteTable-${count.index}"
#     }
# }


resource "aws_route_table" "route_table_private" {
    vpc_id = var.vpc_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = var.gateway_id
    }
    tags = {
        Name = "${terraform.workspace}-GradixRouteTable-0"
    }
}


resource "aws_route_table" "route_table_public" {
    vpc_id = var.vpc_id
    route {
        cidr_block = var.subnet_list[1].cidr_block
        nat_gateway_id = var.nat_gateway_id
        
    }
    tags = {
        Name = "${terraform.workspace}-GradixRouteTable-1"
    }
}

