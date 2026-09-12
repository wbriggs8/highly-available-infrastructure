resource "aws_vpc" "vpc-us-east-1" { 
    cidr_block = "10.0.0.0/16"
}
resource "aws_internet_gateway" "internet-gateway-us-east-1" {
    vpc_id = aws_vpc.vpc-us-east-1.id
}
resource "aws_route_table" "public-route-table" {
    vpc_id = aws_vpc.vpc-us-east-1.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet-gateway-us-east-1.id
    }
}
resource "aws_route_table_association" "public-route-table-association1" {
    subnet_id = aws_subnet.public-subnet1.id
    route_table_id = aws_route_table.public-route-table.id
}
resource "aws_route_table_association" "public-route-table-association2" {
    subnet_id = aws_subnet.public-subnet2.id
    route_table_id = aws_route_table.public-route-table.id
}
resource "aws_route_table_association" "public-route-table-association3" {
    subnet_id = aws_subnet.public-subnet3.id
    route_table_id = aws_route_table.public-route-table.id
}
# ------------------- PUBLIC ROUTE TABLES -----------------
resource "aws_route_table" "application-route-table" {
    vpc_id = aws_vpc.vpc-us-east-1.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat-gateway.id
    }
    # route table for the application subnets, which routes traffic to the NAT gateway for internet access
}
resource "aws_route_table_association" "application-route-table-association1" {
    subnet_id = aws_subnet.application-subnet1.id
    route_table_id = aws_route_table.application-route-table.id
}
resource "aws_route_table_association" "application-route-table-association2" {
    subnet_id = aws_subnet.application-subnet2.id
    route_table_id = aws_route_table.application-route-table.id
}
resource "aws_route_table_association" "application-route-table-association3" {
    subnet_id = aws_subnet.application-subnet3.id
    route_table_id = aws_route_table.application-route-table.id
}
# ------------------- APPLICATION ROUTE TABLES -----------------
resource "aws_route_table" "private-route-table" {
    vpc_id = aws_vpc.vpc-us-east-1.id
}
resource "aws_route_table_association" "private-route-table-association1" {
    subnet_id = aws_subnet.database-subnet1.id
    route_table_id = aws_route_table.private-route-table.id
}
resource "aws_route_table_association" "private-route-table-association2" {
    subnet_id = aws_subnet.database-subnet2.id
    route_table_id = aws_route_table.private-route-table.id
}
resource "aws_route_table_association" "private-route-table-association3" {
    subnet_id = aws_subnet.database-subnet3.id
    route_table_id = aws_route_table.private-route-table.id
}
# ------------------- PRIVATE ROUTE TABLES -----------------
resource "aws_security_group" "public-tier-securitygroup" {
    name = "public-tier-securitygroup"
    description = "HTTP inbound traffic"
    vpc_id = aws_vpc.vpc-us-east-1.id
}
resource "aws_security_group_rule" "public-tier-securitygroup-rule-ingress1" {
    type = "ingress"
    from_port = 80
    to_port = 80
    # HTTP inbound traffic only
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.public-tier-securitygroup.id
}
resource "aws_security_group_rule" "public-tier-securitygroup-rule-ingress2" {
    type = "ingress"
    from_port = 443
    to_port = 443
    # HTTP inbound traffic only
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.public-tier-securitygroup.id
}
resource "aws_security_group_rule" "public-tier-securitygroup-rule-egress" {
    type = "egress"
    from_port = 0
    to_port = 0
    # means all ports ONLY WORKS BECAUSE PROTOCOL IS SET TO -1
    protocol = "-1"
    # means all protocols for example tcp udp icmp etc
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.public-tier-securitygroup.id
}
# ------------------- PUBLIC SECURITY GROUP END -----------------
resource "aws_security_group" "application-tier-securitygroup" {
    name = "application-tier-securitygroup"
    description = "For the application tier, allow inbound traffic from the public security group"
    vpc_id = aws_vpc.vpc-us-east-1.id
}
resource "aws_security_group_rule" "application-tier-securitygroup-rule-ingress1" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    source_security_group_id = aws_security_group.public-tier-securitygroup.id
    security_group_id = aws_security_group.application-tier-securitygroup.id
# open port 80 for HTTP traffic from the public SG to the application SG
}
resource "aws_security_group_rule" "application-tier-securitygroup-rule-ingress2" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    source_security_group_id = aws_security_group.public-tier-securitygroup.id
    security_group_id = aws_security_group.application-tier-securitygroup.id
# open port 443 for HTTPS traffic from the public SG to the application SG
}
resource "aws_security_group_rule" "application-tier-securitygroup-rule-egress" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    # means all protocols for example tcp udp icmp etc
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.application-tier-securitygroup.id
    # supports all outbound traffic from the application SG to the NAT gateway + SSM 
}
# ------------------- APPLICATION TIER SECURITY GROUP END -----------------
resource "aws_security_group" "database-tier-securitygroup" {
    name = "database-tier-securitygroup"
    description = "For the database, allow inbound traffic from the application security group"
    vpc_id = aws_vpc.vpc-us-east-1.id
}
resource "aws_security_group_rule" "database-tier-securitygroup-rule" {
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    source_security_group_id = aws_security_group.application-tier-securitygroup.id
    security_group_id = aws_security_group.database-tier-securitygroup.id
# Open port 3306 for MySQL traffic from the application SG to the database SG
} 
# ----------------- PRIVATE TIER SECURITY GROUPS END -----------------
resource "aws_subnet" "public-subnet1" {
    vpc_id = aws_vpc.vpc-us-east-1.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
}
resource "aws_subnet" "public-subnet2" {
    vpc_id = aws_vpc.vpc-us-east-1.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
}
resource "aws_subnet" "public-subnet3" {
    vpc_id = aws_vpc.vpc-us-east-1.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1c"
}
resource "aws_subnet" "application-subnet1" {
    vpc_id = aws_vpc.vpc-us-east-1.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1a"
}
resource "aws_subnet" "application-subnet2" {
    vpc_id = aws_vpc.vpc-us-east-1.id
    cidr_block = "10.0.5.0/24"
    availability_zone = "us-east-1b"
}
resource "aws_subnet" "application-subnet3" {
    vpc_id = aws_vpc.vpc-us-east-1.id
    cidr_block = "10.0.6.0/24"
    availability_zone = "us-east-1c"
}
resource "aws_subnet" "database-subnet1" {
    vpc_id = aws_vpc.vpc-us-east-1.id
    cidr_block = "10.0.7.0/24"
    availability_zone = "us-east-1a"
}
resource "aws_subnet" "database-subnet2" {
    vpc_id = aws_vpc.vpc-us-east-1.id
    cidr_block = "10.0.8.0/24"
    availability_zone = "us-east-1b"

}
resource "aws_subnet" "database-subnet3" {
    vpc_id = aws_vpc.vpc-us-east-1.id
    cidr_block = "10.0.9.0/24"
    availability_zone = "us-east-1c"

}
# FOUR SUBNETS CREATED, 3 PUBLIC FOR ASG, 1 PRIVATE FOR DATABASE (ONLY 1 FOR FREE TIER)
# ----------------- SUBNETS END -----------------
resource "aws_eip" "eip" {
     domain = "vpc"
     depends_on = [aws_internet_gateway.internet-gateway-us-east-1]
}
resource "aws_nat_gateway" "nat-gateway" {
    allocation_id = aws_eip.eip.id
    # connects Elastic IP to the NAT Gateway
    subnet_id = aws_subnet.public-subnet1.id
}
# in the public subnet, the NAT gateway allows instances in the private subnet to access the internet for updates and patches, while preventing inbound traffic from the internet to the private subnet
#----------------- NAT GATEWAY END -----------------
resource "aws_iam_role" "ssm-iam-role" {
    name = "ssm-iam-role"
    assume_role_policy = jsonencode({
        # "jsonencode" function converts the policy to a JSON string
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                    # allows only the Principal "ec2.amazonaws.com" to assume the role
                }
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "ssm-iam-role-policy-attachment" {
    role = aws_iam_role.ssm-iam-role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}# connects the IAM role to the Amazon SSM Managed Instance Core policy, allowing EC2 instances to use Systems Manager features

resource "aws_iam_instance_profile" "ssm-instance-profile" {
    name = "ssm-instance-profile"
    role = aws_iam_role.ssm-iam-role.name
}# creates an IAM instance profile and associates it with the ssm-iam-role, similar to how an EC2 instance to an EBS Volume its like a container