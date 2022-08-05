terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.16.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public1_cidr_block
  availability_zone = "us-east-1a"
  tags = {
    Name = "public1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public2_cidr_block
  availability_zone = "us-east-1b"
  tags = {
    Name = "public2"
  }
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private1_cidr_block
  availability_zone = "us-east-1a"
  tags = {
    Name = "private1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private2_cidr_block
  availability_zone = "us-east-1b"
  tags = {
    Name = "private2"
  }
}
