/**
* Verify if resource key pair already exist
*/


resource "tls_private_key" "name" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "key_pair_public_instance" {
    key_name = "${terraform.workspace}-GradixKP-PublicInstance"
    public_key = tls_private_key.name.public_key_openssh
}

/*
* Save the private key on local
*/
resource "local_file" "save_key_pair_public_instance" {
  filename = "${terraform.workspace}-GradixKP-PublicInstance.pem"
  content = tls_private_key.name.private_key_pem
}



resource "aws_key_pair" "key_pair_private_instance" {
    key_name = "${terraform.workspace}-GradixKP-PrivateInstance"
    public_key = tls_private_key.name.public_key_openssh
}

/*
* Save the private key on local
*/
resource "local_file" "save_key_pair_private_instance" {
  filename = "${terraform.workspace}-GradixKP-PrivateInstance.pem"
  content = tls_private_key.name.private_key_pem
}



/**
* Create EC2 instance(s)
*/
resource "aws_instance" "instance" {
    count = var.number_ec2_instance
    ami = var.ami
    instance_type               = var.instance_type
    subnet_id                   = count.index > 0 ? var.subnet_list[0].id : var.subnet_list[1].id
    associate_public_ip_address = count.index > 0 ? true : false
    key_name                    = count.index > 0 ? "${terraform.workspace}-GradixKP-PublicInstance" : "${terraform.workspace}-GradixKP-PrivateInstance"
    tags = {
        Name = "${terraform.workspace}-GradixInstance-${count.index}"
    }
    vpc_security_group_ids      = count.index > 0 ? [var.security_group_list[1]]: [var.security_group_list[0]]
    user_data = file("./modules/ec2_instance/user_data.sh")
}