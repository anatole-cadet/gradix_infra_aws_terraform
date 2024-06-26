[![Gradix-Deployment](https://github.com/anatole-cadet/gx_infra_aws_terraform/actions/workflows/gradix-deployment.yml/badge.svg?branch=stage)](https://github.com/anatole-cadet/gx_infra_aws_terraform/actions/workflows/gradix-deployment.yml)



# Gradix

In this project, we deployed cloud infrastructure of Gradix enterprise for one of it's project, with Terraform. 

Considering the architure's diagram below, The simple app will be deploy on three ec2 instances; so for each instance we configured the apache web server and others. We must know also that the Gradix managed a database for it's project. That's the reason why we have another ec2 instance in private subnet; but we will not configure database on it.  

![image](https://github.com/anatole-cadet/gx_infra_aws_terraform/assets/13883209/efc39e7b-f3ea-46ec-aaa8-f9b7f2412c28)


### Project's structure

> [!NOTE]
> Before to show the project structur, we just want to remind that, according to the <a href="https://developer.hashicorp.com/terraform">Hashicorp website</a>, "Terraform is an infrastructure as code tool that lets you build, change, and version infrastructure safely and efficiently. So, as we mentionned, we used it to deploy the cloud infrastructure of gradix.

The structure of the project contains a directory of modules. For each resource created there's a module.

![image](https://github.com/anatole-cadet/gx_infra_aws_terraform/assets/13883209/60ab9b42-a02c-45a1-b19d-ff1f98c5036a)



### Environments and GitHub Action
We created two environments (stage, production) on github, that each is associated to a branch :
- environement stage is associate to the branch stage
- Environement production is associate to the branch production

For each environement, we added an environment secrets. One for the stage environement of the AWS account of stage, another one for the production environement of the AWS account of production
![image](https://github.com/anatole-cadet/gx_infra_aws_terraform/assets/13883209/592377c5-c218-455a-8809-07f30d164c2f)
> [!NOTE]
> For the production environement, it's requeire reviewer before to deploy.
> ![image](https://github.com/anatole-cadet/gx_infra_aws_terraform/assets/13883209/d3c7bfa5-d360-44c2-8e00-a804f498d617)

For each environement, we created some variables. They're used in the workflow. The difference is to the instance type; in production we will launc ec2 instance of type t3.micro. For stage it is t2.micro.
![image](https://github.com/anatole-cadet/gx_infra_aws_terraform/assets/13883209/7d568036-ecb4-4d86-abae-4e75ea821e67)

----------------------------

![image](https://github.com/anatole-cadet/gx_infra_aws_terraform/assets/13883209/2963b5c3-485a-4354-bf46-9e242ef66fff)


<br>



### OpenID Connect (OIDC)
The organisation managed multiple account of AWS. For that, for the stage environment the deployment is made to an AWS account satge; for the prod environment the deployment is made to another AWS account prod. To allow workflows access our resources in AWS, we configured an OIDC (instead of used access_key and secret_key) in each AWS account.
- On push to stage branch : this triggered the worflow and if it's not fail the resources will deploy in the AWS account stage
- On push to prod branch : this triggered the worflow and if it's not fail the resources will deploy in the AWS account production. We remind you that, it's requeire someone to approve the execution of the workflow for this environment.

![image](https://github.com/anatole-cadet/gx_infra_aws_terraform/assets/13883209/5e2c818f-db6a-46e9-938d-0008beb662d8)

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
> The .tfvars file for each branch, was used localy.
![image](https://github.com/anatole-cadet/gx_infra_aws_terraform/assets/13883209/d9d01cb7-5feb-46f7-97bd-1ac38d3473ac)


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


## The result when pushing on stage :

![image](https://github.com/anatole-cadet/gx_infra_aws_terraform/assets/13883209/acac1406-37d1-4d05-a86c-a119b44d516a)
