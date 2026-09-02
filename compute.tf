resource "aws_launch_template" "testlaunchconfiguration" {
    image_id = "ami-0ff8a91507f77f867"
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.testsecuritygroup.id]
}
# 3 PUBLIC SUBNETS, 1 PRIVATE SUBNET FOR DATABASE, 1 VPC
resource "aws_autoscaling_group" "testautoscalinggroup" {
    desired_capacity = 3
    max_size = 6
    min_size = 3
    vpc_zone_identifier = [aws_subnet.public-subnet1.id, aws_subnet.public-subnet2.id, aws_subnet.public-subnet3.id]
    launch_template {
        id = aws_launch_template.testlaunchconfiguration.id
        version = "$Latest"
        
    }
}
resource "aws_autoscaling_policy" "cpuautoscalingpolicy" { 
    name = "cpuautoscalingpolicy"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    autoscaling_group_name = aws_autoscaling_group.testautoscalinggroup.name
}
# adds one EC2 instance to the asg when the alarm triggers the CPU utilization to be greater than 70% for 2 consecutive periods of 120 seconds each
resource "cloudwatch_metric_alarm" "cpucloudwatchalarm" {
    alarm_name = "cpucloudwatchalarm"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = 2
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = 120
    statistic = "Average"
    threshold = 70
    # triggers alarm when the average CPU utilization is greater than 70% for 2 consecutive periods of 120 seconds each

    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.testautoscalinggroup.name
    }

    alarm_actions = [
        aws_autoscaling_policy.testautoscalingpolicy.arn,
        # connects cloudwatch alarm to the autoscaling policy to trigger it
        aws_sns_topic.testsnstopic.asg_alerts.arn
        # connects cloudwatch alarm to the sns topic to send an alert when the alarm is triggered
    ]
}    
resource "aws_sns_topic" "testsnstopic" {
    name = "testsnstopic"
}
resource "aws_sns_topic_subscription" "testsnstopicsubscription" {
    topic_arn = aws_sns_topic.testsnstopic.arn
    # connects the sns topic subscription to the sns topic resource
    protocol = "email"
    # protocl is for where you want the SNS to send the alert, in this case email
    endpoint = "williambriggs912@gmail.com"
}