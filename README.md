[![Gradix-Deployment](https://github.com/anatole-cadet/gx_infra_aws_terraform/actions/workflows/gradix-deployment.yml/badge.svg?branch=stage)](https://github.com/anatole-cadet/gx_infra_aws_terraform/actions/workflows/gradix-deployment.yml)



# Gradix

In this project, we deployed cloud infrastructure of the gradixApp with Terraform. 

Considering the architure's diagram below, The app will be deploy on three ec2 instances; so for each instance we configured the apache web server and others. We must know also that the Gradix managed the database. That's the reason why we have another ec2 instance in private subnet.  

![image](https://github.com/anatole-cadet/gx_infra_aws_terraform/assets/13883209/efc39e7b-f3ea-46ec-aaa8-f9b7f2412c28)


### Project's structure

> [!NOTE]
> Before to show the project structur, we just want to remind that, according to the <a href="https://developer.hashicorp.com/terraform">Hashicorp website</a>, "Terraform is an infrastructure as code tool that lets you build, change, and version infrastructure safely and efficiently. So, as we mentionned, we used it to deploy the cloud infrastructure of gradix.

The structure of the project contains a directory of modules. For each resource created there's a module.

![image](https://github.com/anatole-cadet/gx_infra_aws_terraform/assets/13883209/60ab9b42-a02c-45a1-b19d-ff1f98c5036a)



### Environments and GitHub Action
We created two environments (stage, prod) on github, that each is associated a branch ( in rulesets). 

### OpenID Connect (OIDC)
The organisation managed multiple account of AWS. For that, for the stage environment the deployment is made to an AWS account satge; for the prod environment the deployment is made to another AWS account prod. To allow workflows access our resources in AWS, we configured an OIDC (instead of used access_key and secret_key) in each AWS account.
- On push to stage branch : this triggered the worflow and if it's not fail the resources will deploy in the AWS account stage
- On push to prod branch : this triggered the worflow and if it's not fail the resources will deploy in the AWS account prod. Notice that, it's requeire someone to approve the execution of the workflow for this environment.

In each concerned AWS account there is a s3 bucket for the state file. 

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

### Terraform configuration
Depending on the working branch, Terraform created all the resources include subnets, routes table, ec2 instances and others when usin the appropriate .tfvars. It means that resources was created depending the informations given in the <b>.tfvars</b> files : .<br>
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


## The result when pushing on stage branch :

![image](https://github.com/anatole-cadet/gx_infra_aws_terraform/assets/13883209/548e0a64-f120-4968-956a-4bf373a0c37b)
