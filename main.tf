/**
* Module to create VPC
*/
module "vpc_module" {
  source = "./modules/vpc"
  vpc_tag_name = var.vpc_tag_name
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
}

/**
* Create route table for subnet. The number route table to create equal to the number
* of subnet
*/
module "route_table" {
  source = "./modules/route_table"
  number_route_table = module.subnet_module.number_subnet_created
  vpc_id = module.vpc_module.vpc_id
  subnet_list = module.subnet_module.subnet_output
  gateway_id = module.internet_gateway_module.internet_gateway_output
}

/**
* Create the route table association for associate subnet to each route table
* Then, the number of route table is equal to the number of subnet.
*/
module "route_table_association" {
  source = "./modules/route_table_association"
  count = var.number_subnet
  subnet_id = module.subnet_module.subnet_output[count.index].id
  route_table_id = module.route_table.route_table_output[count.index].id
}

/**
* Module to create internet gateway
*/
module "internet_gateway_module" {
  source = "./modules/internet_gateway"
  vpc_id = module.vpc_module.vpc_id
}