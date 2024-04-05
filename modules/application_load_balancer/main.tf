/*
* Create Application Load Balancer.
* We specified the list of the subnet; and the security group 1 that is for public subnet.
*/
resource "aws_lb" "application_load_balancer" {
  name = "${terraform.workspace}-GradixALB"
  load_balancer_type = "application"
  enable_deletion_protection = false
  subnets = [ for sbn in var.list_subnet : sbn.id]
  security_groups = [var.list_security_group[1]] #[ for sg in var.list_security_group : sg.id][0]
  ip_address_type = "ipv4"
  tags = {
    Name = "${terraform.workspace}-GradixALB"
  }
  
}

/**
* Create the target group
*/
resource "aws_lb_target_group" "alb_target_group" {
  name = "${terraform.workspace}-GradixTargetGroup"
  vpc_id = var.vpc_id
  port = 80
  protocol = "HTTP"
  target_type = "instance"
  health_check {
    enabled = true
  }
  #depends_on = [ var.depends_on_resource ]
  
}


/**
* For the listerner
*/
resource "aws_lb_listener" "application_load_balancer_listerner" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  protocol = "HTTP"
  port = 80
  default_action {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    type = "forward"

  }
}



/*
* Register the instance(s)
*/
resource "aws_lb_target_group_attachment" "target_group_attachment" {
    count = length(var.list_ec2_instance_to_register)
    port = 80
    target_id = var.list_ec2_instance_to_register[count.index].id
    target_group_arn = aws_lb_target_group.alb_target_group.arn
}


