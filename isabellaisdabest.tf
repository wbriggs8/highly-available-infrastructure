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
resource "aws_subnet" "testsubnet" {
    vpc_id = aws_vpc.testvpc.id
    cidr_block = "10.0.0.0/24"
}
resource "aws_instance" "testinstance" {
    ami = "ami-0ff8a91507f77f867"
    instance_type = "t3.micro"
    subnet_id = aws_subnet.testsubnet.id
    vpc_security_group_ids = [aws_security_group.testsecuritygroup.id]
}