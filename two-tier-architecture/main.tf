terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.16.0"
    }
  }
}

## configuring aws as provider
provider "aws" {
  region = var.aws_region
}

## creating vpc
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
  tags       = { Name = "my_vpc" }
}

## creating two public subnets in two different availability zones
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_cidr_block[0]
  availability_zone       = var.az[0]
  map_public_ip_on_launch = true
  tags                    = { Name = "public1" }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_cidr_block[1]
  availability_zone       = var.az[1]
  map_public_ip_on_launch = true
  tags                    = { Name = "public2" }
}

## creating two private subnets in two different availability zones
resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.private_cidr_block[0]
  availability_zone       = var.az[0]
  map_public_ip_on_launch = false
  tags                    = { Name = "private1" }
}

resource "aws_subnet" "private2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.private_cidr_block[1]
  availability_zone       = var.az[1]
  map_public_ip_on_launch = false
  tags                    = { Name = "private2" }
}

## creating an internet gateway to connect to the internet 
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags   = { Name = "my_igw" }
}

## create route table and attach internet gateway
resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = { Name = "my_rt" }
}

## adding the two public subnets to the route table
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.my_rt.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.my_rt.id
}

## creating the application load balancer
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]
}

## creating target group for the application load balancer
resource "aws_lb_target_group" "my_alb_tg" {
  name       = "alb-tg"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = aws_vpc.my_vpc.id
  depends_on = [aws_vpc.my_vpc]
}

## attach webtier instances to target group
resource "aws_lb_target_group_attachment" "webserver1_tg" {
  target_group_arn = aws_lb_target_group.my_alb_tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
  depends_on       = [aws_instance.webserver1]
}

resource "aws_lb_target_group_attachment" "webserver2_tg" {
  target_group_arn = aws_lb_target_group.my_alb_tg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
  depends_on       = [aws_instance.webserver2]
}

## creating alb listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_alb_tg.arn
  }
}

## creating security group for alb
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "application load balancer security group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## creating the security group for web-tier
resource "aws_security_group" "webtier_sg" {
  name        = "webtier-sg"
  description = "SSH and HTTP"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "ssh into instance"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow http traffic from webserver"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## create security group for the data tier
resource "aws_security_group" "datatier_sg" {
  name        = "database-sg"
  description = "SSH"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description     = "ssh into database from webtier"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.webtier_sg.id]
  }

  ingress {
    description     = "ssh into database"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.webtier_sg.id]
    cidr_blocks     = var.public_cidr_block
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## creating two ec2 instances in both public subnets and adding bootstrap script to them, which will install nginx on them
resource "aws_instance" "webserver1" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public1.id
  vpc_security_group_ids = [aws_security_group.webtier_sg.id]
  key_name               = "DylanKey"
  user_data              = file("nginx_script.sh")
  tags                   = { Name = "NGINX_server" }
}

resource "aws_instance" "webserver2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public2.id
  vpc_security_group_ids = [aws_security_group.webtier_sg.id]
  key_name               = "DylanKey"
  user_data              = file("script_nginx.sh")
  tags                   = { Name = "NGINX_server" }
}

## create rds mysql instaces
resource "aws_db_instance" "database" {
  allocated_storage      = var.allocated_storage
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  name                   = var.db_name
  username               = var.username
  password               = var.password
  db_subnet_group_name   = aws_db_subnet_group.my-db-subnet.id
  vpc_security_group_ids = [aws_security_group.datatier_sg.id]
  skip_final_snapshot    = true
}

## create subnet group for the database
resource "aws_db_subnet_group" "my-db-subnet" {
  name       = "my-db-subnet"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
}