variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for my_vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public1_cidr_block" {
  description = "CIDR block for Public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public2_cidr_block" {
  description = "CIDR block for Public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private1_cidr_block" {
  description = "CIDR block for Private subnet 1"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private2_cidr_block" {
  description = "CIDR block for Private subnet 2"
  type        = string
  default     = "10.0.4.0/24"
}


