terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "testbucket" {
    bucket = "williambriggsisdaworst"
}
resource "aws_vpc" "testvpc" { 
    cidr_block = "10.0.0.0/16"
}
resource "aws_security_group" "testsecuritygroup" {
    name = "testsecuritygroup"
    description = "Allow SSH and HTTP inbound traffic cuh"
    vpc_id = aws_vpc.testvpc.id
}
resource "aws_security_group_rule" "testsecuritygrouprule" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0", "::/0"]
    security_group_id = aws_security_group.testsecuritygroup.id
}
resource "aws_subnet" "testsubnet1" {
    vpc_id = aws_vpc.testvpc.id
    cidr_block = "10.0.1.0/24"
}
resource "aws_subnet" "testsubnet2" {
    vpc_id = aws_vpc.testvpc.id
    cidr_block = "10.0.2.0/24"
}
resource "aws_subnet" "testsubnet3" {
    vpc_id = aws_vpc.testvpc.id
    cidr_block = "10.0.3.0/24"
}
resource "aws_autoscaling_group" "testautoscalinggroup" {
    desired_capacity = 3
    max_size = 6
    min_size = 3
    vpc_zone_identifier = [aws_subnet.testsubnet1.id, aws_subnet.testsubnet2.id, aws_subnet.testsubnet3.id]
    launch_template {
        id = aws_launch_template.testlaunchconfiguration.id
        version = "$Latest"
    }
    
}
resource "aws_launch_template" "testlaunchconfiguration" {
    image_id = "ami-0ff8a91507f77f867"
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.testsecuritygroup.id]
}
resource "aws_autoscaling_policy" "testautoscalingpolicy" { 
    name = "testautoscalingpolicy"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    autoscaling_group_name = aws_autoscaling_group.testautoscalinggroup.name
}
# NEED TO CREATE CLOUDWATCH ALARM FOR AUTOSCALING POLICY
resource "aws_lb" "testloadbalancer" {
    name = "testloadbalancer"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.testsecuritygroup.id]
    subnets = [aws_subnet.testsubnet1.id, aws_subnet.testsubnet2.id, aws_subnet.testsubnet3.id]
    
}
resource "aws_lb_target_group" "testtargetgroup" {
    name = "testtargetgroup"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.testvpc.id
}
resource "aws_lb_listener" "testloadbalancerlistener" {
    load_balancer_arn = aws_lb.testloadbalancer.arn
    port = 80
    protocol = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.testtargetgroup.arn
    }
} 
# Will review and edit later
resource "aws_autoscaling_attachment" "testtargetgroupattachment" {
    autoscaling_group_name = aws_autoscaling_group.testautoscalinggroup.name
    lb_target_group_arn = aws_lb_target_group.testtargetgroup.arn
}
# Will review and edit later
resource "rds_instance" "testrdsinstance" {
    allocated_storage = 20
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
    name = "testdb"
    username = "admin"
    password = data.aws_secretsmanager_secret_version.db_password.secret_string
    parameter_group_name = "default.mysql8.0"
    skip_final_snapshot = true
    vpc_security_group_ids = [aws_security_group.testsecuritygroup.id]
    db_subnet_group_name = aws_db_subnet_group.testdbsubnetgroup.name
}
# CREATE SECRETS MANAGER PARAMETERS FOR PASSWORDS
