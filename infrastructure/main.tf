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
  vpc_security_group_ids = [ module.security.jenkins_security_group_id ]
  key_name        = var.key_name
  user_data       = templatefile("${path.module}/scripts/jenkins-setup.sh", {})
  tags            = merge(local.common_tags, { Name = "${local.name}-Jenkins-Serever" })
    # Configure the root volume
  root_block_device {
    volume_type = "gp3"
    volume_size = 30       # Size in GiB
    delete_on_termination = true
  }
}

resource "aws_instance" "nexus" {
  ami             = "ami-013f478ef10960da1"
  instance_type   = var.instance_type
  subnet_id       = element(module.vpc.public_subnet_ids, 1)
  vpc_security_group_ids = [ module.security.nexus_security_group_id ]
  key_name        = var.key_name
  user_data       = templatefile("${path.module}/scripts/nexus-ubuntu-new.sh",{})
  tags            = merge(local.common_tags, { Name = "${local.name}-nexus-Serever" })
  # Configure the root volume
  root_block_device {
    volume_type = "gp3"
    volume_size = 30       # Size in GiB
    delete_on_termination = true
  }
}

resource "aws_instance" "sonar" {
  ami             = "ami-013f478ef10960da1"
  instance_type   = var.instance_type
  subnet_id       = element(module.vpc.public_subnet_ids, 1)
  vpc_security_group_ids = [ module.security.sonar_security_group_id ]
  key_name        = var.key_name
  user_data       = templatefile("${path.module}/scripts/sonar-setup.sh",{})
  tags            = merge(local.common_tags, { Name = "${local.name}-sonar-Serever" })
  # Configure the root volume
  root_block_device {
    volume_type = "gp3"
    volume_size = 30       # Size in GiB
    delete_on_termination = true
  }
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
  depends_on = [ aws_instance.jenkins ]
}

resource "aws_route53_record" "route53_A_record_nexus" {
  zone_id = data.aws_route53_zone.selected_zone.zone_id
  name    = "nexus.${var.root_domain_name}"
  type    = "A"
  ttl = 300
  records = [aws_instance.nexus.public_ip]
  depends_on = [ aws_instance.nexus ]
}


resource "aws_route53_record" "route53_A_record_sonar" {
  zone_id = data.aws_route53_zone.selected_zone.zone_id
  name    = "sonar.${var.root_domain_name}"
  type    = "A"
  ttl = 300
  records = [aws_instance.sonar.public_ip]
  depends_on = [ aws_instance.nexus ]
}
