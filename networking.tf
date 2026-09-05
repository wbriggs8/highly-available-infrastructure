resource "aws_vpc" "testvpc" { 
    cidr_block = "10.0.0.0/16"
}
resource "aws_internet_gateway" "testinternetgateway" {
    vpc_id = aws_vpc.testvpc.id
}
resource "aws_route_table" "testpublicroutetable" {
    vpc_id = aws_vpc.testvpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.testinternetgateway.id
    }
}

resource "aws_route_table_association" "testpublicroutetableassociation1" {
    subnet_id = aws_subnet.public-subnet1.id
    route_table_id = aws_route_table.testpublicroutetable.id
}
resource "aws_route_table_association" "testpublicroutetableassociation2" {
    subnet_id = aws_subnet.public-subnet2.id
    route_table_id = aws_route_table.testpublicroutetable.id
}
resource "aws_route_table_association" "testpublicroutetableassociation3" {
    subnet_id = aws_subnet.public-subnet3.id
    route_table_id = aws_route_table.testpublicroutetable.id
}
resource "aws_route_table" "testprivateroutetable" {
    vpc_id = aws_vpc.testvpc.id
}
# ------------------- ROUTE TABLES -----------------
resource "aws_security_group" "public-tier-securitygroup" {
    name = "public-tier-securitygroup"
    description = "HTTP inbound traffic"
    vpc_id = aws_vpc.testvpc.id
}
resource "aws_security_group_rule" "public-tier-securitygroup-rule" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0", "::/0"]
    security_group_id = aws_security_group.public-tier-securitygroup.id
}
# ------------------- PUBLIC TIER SECURITY GROUP END -----------------
resource "aws_security_group" "private-tier-securitygroup" {
    name = "private-tier-securitygroup"
    description = "For the database, allow inbound traffic from the public security group"
    vpc_id = aws_vpc.testvpc.id
}
resource "aws_security_group_rule" "private-tier-securitygroup-rule" {
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    source_security_group_id = aws_security_group.public-tier-securitygroup.id
    security_group_id = aws_security_group.private-tier-securitygroup.id
# Open port 3306 for MySQL traffic from the public SG to the private SG
}

# ----------------- PRIVATE TIER SECURITY GROUPS END -----------------
resource "aws_subnet" "public-subnet1" {
    vpc_id = aws_vpc.testvpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
}
resource "aws_subnet" "public-subnet2" {
    vpc_id = aws_vpc.testvpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
}
resource "aws_subnet" "public-subnet3" {
    vpc_id = aws_vpc.testvpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1c"
}
resource "aws_subnet" "private-subnet" {
    vpc_id = aws_vpc.testvpc.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1a"

}
# FOUR SUBNETS CREATED, 3 PUBLIC FOR ASG, 1 PRIVATE FOR DATABASE (ONLY 1 FOR FREE TIER)
# ----------------- SUBNETS END -----------------
