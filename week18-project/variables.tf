## provider
variable "aws_region" {
  description = "Configuring AWS as provider"
  type        = string
  default     = "us-east-1"
}

## vpc variable
variable "vpc_cidr_block" {
  description = "CIDR block for my_vpc"
  type        = string
  default     = "10.0.0.0/16"
}

## subnet variables
variable "public_cidr_block" {
  description = "CIDR blocks for Public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_cidr_block" {
  description = "CIDR blocks for Private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

## availability zone variable
variable "az" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

## ec2 variables
variable "instance_type" {
  description = "AWS EC2 instance type."
  type        = string
  default     = "t2.micro"
}

variable "ami" {
  description = "ID of Ubuntu AMI to use for the instance"
  type        = string
  default     = "ami-052efd3df9dad4825"
}

## rds mysql variables
variable "allocated_storage" {
  description = "Allocated storage in gigabytes"
  type        = number
  default     = 8
}

variable "engine" {
  description = "Engine to use for database"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "Engine version to use"
  type        = string
  default     = "5.7"
}

variable "instance_class" {
  description = "Instance type for RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Name of database"
  type        = string
  default     = "my_db"
}

variable "username" {
  description = "Username for the DB user"
  type        = string
  default     = "admin"
}

variable "password" {
  description = "Password for the DB user"
  type        = string
  default     = "admin123"
}
