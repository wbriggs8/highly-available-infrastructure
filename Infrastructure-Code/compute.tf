resource "aws_launch_template" "main-launchconfiguration-webserver" {
    image_id = "ami-081b0a6eac00b4f53"
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.application-tier-securitygroup.id]
    iam_instance_profile {
        name = aws_iam_instance_profile.ec2-instance-profile.name
    }
    # tells the template to use the instance profile on ssm and secrets manager for all instances using the template
    depends_on = [
        aws_efs_mount_target.wp-efs-mount-target1,
        aws_efs_mount_target.wp-efs-mount-target2,
        aws_efs_mount_target.wp-efs-mount-target3
  ]
    user_data = base64encode(templatefile("${path.module}/user_data.sh", {
        efs_id = aws_efs_file_system.wp-efs-file-system.id
        db_host = aws_db_instance.main-rds-instance.address
        db_name = aws_db_instance.main-rds-instance.db_name
        username = aws_db_instance.main-rds-instance.username
  # all 4 variables are injected into the user_data.sh file on start up instead of being hardcoded
}))

}
# 3 PUBLIC SUBNETS, 1 PRIVATE SUBNET FOR DATABASE, 1 VPC
resource "aws_autoscaling_group" "main-autoscaling-group" {
    name = "main-autoscaling-group"
    desired_capacity = 3
    max_size = 6
    min_size = 3
    target_group_arns = [aws_lb_target_group.load-balancer-target-group.arn]
    # references the alb target group it will be attached to
    vpc_zone_identifier = [aws_subnet.application-subnet1.id, aws_subnet.application-subnet2.id, aws_subnet.application-subnet3.id]
    launch_template {
        id = aws_launch_template.main-launchconfiguration-webserver.id
        version = "$Latest"
        # references the launch template
    }
}
resource "aws_autoscaling_policy" "cpu-autoscaling-policy" { 
    name = "cpu-autoscaling-policy"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    autoscaling_group_name = aws_autoscaling_group.main-autoscaling-group.name
}
# adds one EC2 instance to the asg when the alarm triggers the CPU utilization to be greater than 70% for 2 consecutive periods of 120 seconds each
resource "aws_cloudwatch_metric_alarm" "cpu-cloudwatch-alarm" {
    alarm_name = "cpu-cloudwatch-alarm"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = 2
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = 120
    statistic = "Average"
    threshold = 70
    # triggers alarm when the average CPU utilization is greater than 70% for 2 consecutive periods of 120 seconds each

    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.main-autoscaling-group.name
    }

    alarm_actions = [
        aws_autoscaling_policy.cpu-autoscaling-policy.arn,
        # connects cloudwatch alarm to the autoscaling policy to trigger it
        aws_sns_topic.cpu-sns-topic.arn
        # connects cloudwatch alarm to the sns topic to send an alert when the alarm is triggered
    ]
}    
resource "aws_sns_topic" "cpu-sns-topic" {
    name = "cpu-sns-topic"
    kms_master_key_id = aws_kms_key.main-kms-key.arn
}
resource "aws_sns_topic_subscription" "cpu-sns-topic-subscription" {
    topic_arn = aws_sns_topic.cpu-sns-topic.arn
    # connects the sns topic subscription to the sns topic resource
    protocol = "email"
    # protocl is for where you want the SNS to send the alert, in this case email
    endpoint = "youremail@example.com"
}