locals {
  name = "${var.project_name}-${var.environment}"
  common_tags = {
    Environment = "${var.environment}"
    CreatedBy   = "Terraform"
  }
  my_ip_cidr = "${chomp(data.http.my_ip.body)}/32"
}

data "http" "my_ip" {
  url = "https://ipv4.icanhazip.com"
}

module "vpc" {
  source          = "./modules/vpc"
  environment     = var.environment
  project_name    = var.project_name
  vpc_cidr        = var.vpc_cidr
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  azs             = var.availability_zones
}

module "security" {
  source       = "./modules/security"
  environment  = var.environment
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  allowed_ssh_cidr_blocks = local.my_ip_cidr

}

resource "aws_instance" "jenkins" {
  ami = "ami-013f478ef10960da1"
  instance_type = var.instance_type
  subnet_id = element(module.vpc.public_subnet_ids, 0)
  security_groups = [ module.security.jenkins_sg.id ]
  key_name = var.key_name
  user_data = base64encode(templatefile("${path.module}/scripts/jenkins-setup.sh", {}))
  tags                   = merge(local.common_tags, { Name = "${local.name}-Jenkins-Serever" })

}
