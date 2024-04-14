/**
* Module to create VPC
*/
module "vpc_module" {
  source = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
}


/**
* Module to create subnet(s)
*/
module "subnet_module" {
  source = "./modules/subnet"
  number_subnet = tonumber(var.number_subnet)
  vpc_id = module.vpc_module.vpc_id
  cidr_block_vpc = module.vpc_module.vpc_cidr_block_output
  environment = var.environment
}

/**
* Module to create internet gateway
*/
module "internet_gateway_module" {
  source = "./modules/internet_gateway"
  vpc_id = module.vpc_module.vpc_id
  environment = var.environment
}

/**
* Create route table for subnet. The number of route table to create is equal to the number
* of subnet given in the .tfvars
*/
module "route_table" {
  source = "./modules/route_table"
  number_route_table = module.subnet_module.number_subnet_created
  vpc_id = module.vpc_module.vpc_id
  subnet_list = module.subnet_module.subnet_output
  gateway_id = module.internet_gateway_module.internet_gateway_output
  nat_gateway_id = module.nat_gateway_module.nat_gateway_id_output
  depends_on = [ module.subnet_module ]
  environment = var.environment
}

/**
* Create the route table association for associate a subnet to each route table
* The number of route table is equal to the number of subnet given in the .tfvars.
*/
module "route_table_association" {
  source = "./modules/route_table_association"
  count = var.number_subnet
  subnet_id = module.subnet_module.subnet_output[count.index].id
  route_table_id =module.route_table.route_table_id_output[count.index] #module.route_table.route_table_output[count.index].id
}


/**
* Create the NatGateWay. We choose the first subnet to attach to the NatGateWay,
* This subnet is the public subnet.
*/
module "nat_gateway_module" {
  source = "./modules/nat_gateway"
  subnet_id = module.subnet_module.subnet_output[0].id
  environment = var.environment
}

/**
* Create the security groups
*/
module "security_group_module" {
  source = "./modules/security_group"
  vpc_id = module.vpc_module.vpc_id
  environment = var.environment
}

module "ec2_instance_module" {
  source = "./modules/ec2_instance"
  ami = var.ami
  instance_type = var.instance_type
  subnet_list = module.subnet_module.subnet_output
  number_ec2_instance = var.number_ec2_instance
  security_group_list = module.security_group_module.security_group_id_output  #module.security_group_module.security_group_list_output
environment = var.environment
}



/**
* Create Application Load Balancer, target group and 
*/
module "application_load_balancer" {
  source = "./modules/application_load_balancer"
  vpc_id = module.vpc_module.vpc_id
  list_security_group = module.security_group_module.security_group_id_output  #module.security_group_module.security_group_list_output
  list_subnet = module.subnet_module.subnet_output
  list_ec2_instance_to_register = module.ec2_instance_module.list_instance_to_register_output
  depends_on = [ module.ec2_instance_module ]
  environment = var.environment
}