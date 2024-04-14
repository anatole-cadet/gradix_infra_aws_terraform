<img alt="Static Badge" src="https://img.shields.io/badge/status-development-blue">



# Gradix

In this project, we deployed cloud infrastructure of the gradixApp with Terraform. 

Considering the architure's diagram below, The app will be deploy on three ec2 instances; so for each instance we configured the apache web server and others. We must know also that the Gradix managed the database. That's the reason why we have another ec2 instance in private subnet.  

![image](https://github.com/anatole-cadet/gx_infra_aws_terraform/assets/13883209/efc39e7b-f3ea-46ec-aaa8-f9b7f2412c28)


### Project's structure

> [!NOTE]
> Before to show the project structur, we just want to remind that, according to the <a href="https://developer.hashicorp.com/terraform">Hashicorp website</a>, "Terraform is an infrastructure as code tool that lets you build, change, and version infrastructure safely and efficiently. So, as we mentionned, we used it to deploy the cloud infrastructure of gradix.

The structure of the project contain a directory of modules. For each resource created there's a module.

![image](https://github.com/anatole-cadet/gx_infra_aws_terraform/assets/13883209/60ab9b42-a02c-45a1-b19d-ff1f98c5036a)


We created two workspace <b>dev</b> and <b>stage</b>, inside each one will have the state file. State file is the file thta terraform create when we deployed. This file conatain all the information about each resource that created. As it can contain sensitive informations, we choose to store the in S3 Bucket. And as we created workspace, a state file will create for each environement. Notice that each environment has it's own informations configuration in a .tfvars file. 
In S3 bucket <b>gradix-terraform-state</b>, you will see two directory named dev/ and stage/.

<b>backend.tf</b>
```terraform
terraform {
  backend "s3" {
    bucket = "gradix-terraform-state"
    encrypt = true
    region = "ca-central-1"
    key = "terraform.tfstate"
    dynamodb_table = "gradix-dynamodb-state-locking"
  }
}
```

![gradix_command_1](https://github.com/anatole-cadet/gradix_infra_aws_terraform/assets/13883209/e73d0e4c-4248-49be-a4ca-6c86715062fb)



### Terraform configuration
As mentionned above, we created two workspace : dev, stage. With the .tfvars, Terraform created all the resources include subnets, routes table, ec2 instances. It means that resources was created depending the informations given in the <b>.tfvars</b> files : .<br>
- <b>vpc_cidr_block :</b> The cidr of the VPC<br>
- <b>number_subnet  :</b> The number of subnet that we want to create in the VPC. The variables.tf contain a validation data this number must be smaller than 7<br>
  
```terraform
  variable "number_subnet" {
  description = "The number of subnet to create"
  type = number
  nullable = false
  validation {
    condition = var.number_subnet < 7
    error_message = "The number of subnet must be smaller than 7"
  }
}
```

- <b>region         :</b> The region of the VPC<br>
- <b>number_ec2_instance : </b> The number of instance to created. The variables.tf contain a validation data that this number must be between 2 and 5. And whatever the number of instance, the first instance is the private.


```terraform
variable "number_ec2_instance" {
  description = "The number of instance to create"
  type = number
  nullable = false
  validation {
    condition = var.number_ec2_instance > 1 && var.number_ec2_instance < 6
    error_message = "The number of instance to create must be between 2 and 5."
  }
}
```

- <b>instance_type   :</b> The instance type of the ec2 instances<br>
- <b>ami             :</b> The AMI (Amazon machin image)

> [!NOTE]
> As we decided that each subnet has his own table route; then we created two routes tables. Then in the <b>main.tf</b> of the root, the module for creating the routes table was implemented as bellow :
 ```terraform
 /**
 * Create the route table association for associate a subnet to each route table
 * The number of route table is equal to the number of subnet given in the .tfvars.
 */
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
 ```

 > [!NOTE]
> According to security group, terraform created two security group : one for all the publics instances and another one for the private instance on which the database is. 

