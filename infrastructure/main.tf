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
  source                  = "./modules/security"
  environment             = var.environment
  project_name            = var.project_name
  vpc_id                  = module.vpc.vpc_id
  allowed_ssh_cidr_blocks = "0.0.0.0/0"

}

resource "aws_instance" "jenkins" {
  ami             = "ami-013f478ef10960da1"
  instance_type   = var.instance_type
  subnet_id       = element(module.vpc.public_subnet_ids, 0)
  security_groups = [ module.security.jenkins_security_group_id ]
  key_name        = var.key_name
  user_data       = templatefile("${path.module}/scripts/jenkins-setup.sh", {})
  tags            = merge(local.common_tags, { Name = "${local.name}-Jenkins-Serever" })
}

resource "aws_instance" "nexus" {
  ami             = "ami-013f478ef10960da1"
  instance_type   = var.instance_type
  subnet_id       = element(module.vpc.public_subnet_ids, 1)
  security_groups = [ module.security.nexus_security_group_id ]
  key_name        = var.key_name
  user_data       = templatefile("${path.module}/scripts/nexus-ubuntu.sh", {})
  tags            = merge(local.common_tags, { Name = "${local.name}-nexus-Serever" })
}

data "aws_route53_zone" "selected_zone" {
  name         =var.root_domain_name
  private_zone = false
}

resource "aws_route53_record" "route53_A_record" {
  zone_id = data.aws_route53_zone.selected_zone.zone_id
  name    = "jenkins.${var.root_domain_name}"
  type    = "A"
  ttl = 300
  records = [aws_instance.jenkins.public_ip]
}

resource "aws_route53_record" "route53_A_record_nexus" {
  zone_id = data.aws_route53_zone.selected_zone.zone_id
  name    = "nexus.${var.root_domain_name}"
  type    = "A"
  ttl = 300
  records = [aws_instance.nexus.public_ip]
}

