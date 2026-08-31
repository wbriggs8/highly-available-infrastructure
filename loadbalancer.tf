resource "aws_lb" "testloadbalancer" {
    name = "testloadbalancer"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.testsecuritygroup.id]
    subnets = [aws_subnet.testsubnet1.id, aws_subnet.testsubnet2.id, aws_subnet.testsubnet3.id]
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
resource "aws_lb_target_group" "testtargetgroup" {
    name = "testtargetgroup"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.testvpc.id
}
# ALB receives internet traffic
# the listener listens in and decides which target group to send the traffic to
# the target group sends the traffic to the instances in the autoscaling group