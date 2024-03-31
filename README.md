# Gradix

In this project, we are going to deploy cloud infrastructure of the gradixApp with Terraform. 

Considering the architure's diagram below, The app will be deploy on three ec2 instances; so for each instance we are going to configure the apache web server and others. We must know also thatThe Gradix team would like to manage it's database in a ec2 instance. The, in this one we will install the postgresSQL

![gradix_network](https://github.com/anatole-cadet/gradix_network_aws/assets/13883209/be8d487b-9d67-4d7d-98bf-59c1de80a34a)


### Project's structure
Before to show the project structur, we just want to remind that, according to the <a href="https://developer.hashicorp.com/terraform">Hashicorp website</a>, "Terraform is an infrastructure as code tool that lets you build, change, and version infrastructure safely and efficiently. So, as we mentionned, we used it to deploy the cloud infrastructure of gradix.




