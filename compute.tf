resource "aws_launch_template" "testlaunchconfiguration" {
    image_id = "ami-0ff8a91507f77f867"
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.testsecuritygroup.id]
}
# 3 PUBLIC SUBNETS, 1 PRIVATE SUBNET FOR DATABASE, 1 VPC, 1 SECURITY GROUP
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
resource "aws_autoscaling_policy" "testautoscalingpolicy" { 
    name = "testautoscalingpolicy"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    autoscaling_group_name = aws_autoscaling_group.testautoscalinggroup.name
}
# NEED TO CREATE CLOUDWATCH ALARM FOR AUTOSCALING POLICY