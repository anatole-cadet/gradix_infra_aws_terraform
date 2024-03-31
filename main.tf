
module "vpc_module" {
  source = "./modules/vpc"
  vpc_tag_name = var.vpc_tag_name
  vpc_cidr_block = var.vpc_cidr_block
}


module "subnet_module" {
  source = "./modules/subnet"
  number_subnet = var.number_subnet
  vpc_id = module.vpc_module.vpc_id
}