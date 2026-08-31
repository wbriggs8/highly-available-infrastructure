resource "aws_vpc" "testvpc" { 
    cidr_block = "10.0.0.0/16"
}
resource "aws_security_group" "testsecuritygroup" {
    name = "testsecuritygroup"
    description = "Allow SSH and HTTP inbound traffic cuh"
    vpc_id = aws_vpc.testvpc.id
}
resource "aws_security_group" "testsecuritygroupprivate" {
    name = "testsecuritygroupprivate"
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
resource "aws_security_group_rule" "testsecuritygrouprule" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0", "::/0"]
    security_group_id = aws_security_group.testsecuritygroup.id
}
# ----------------- SECURITY GROUPS END -----------------
resource "aws_subnet" "testsubnet1" {
    vpc_id = aws_vpc.testvpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
}
resource "aws_subnet" "testsubnet2" {
    vpc_id = aws_vpc.testvpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
}
resource "aws_subnet" "testsubnet3" {
    vpc_id = aws_vpc.testvpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1c"
}
resource "aws_subnet" "testprivatesubnet" {
    vpc_id = aws_vpc.testvpc.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1a"

}
# FOUR SUBNETS CREATED, 3 PUBLIC FOR ASG, 1 PRIVATE FOR DATABASE (ONLY 1 FOR FREE TIER)
# ----------------- SUBNETS END -----------------
