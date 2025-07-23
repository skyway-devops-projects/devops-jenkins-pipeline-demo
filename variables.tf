variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "iam_user_name" {
  type = string
}
variable "bucket_name" {
  type = string
}
variable "table_name" {
  type = string
}
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet CIDR blocks"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet CIDR blocks"
}



variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_type_bastion" {
  description = "EC2 instance type"
  type        = string
}

variable "domain_name" {
  description = "Domain Name"
  type        = string
}



variable "bucket_artifact_storage" {
  type = string
}



variable "root_domain_name" {
  type    = string
}

# variable "record" {
#   description =  "Records Ip"
#   type = list(string)
# }