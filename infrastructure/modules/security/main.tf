locals {
  name = "${var.project_name}-${var.environment}"
  common_tags = {
    Environment = "${var.environment}"
    CreatedBy   = "Terraform"
  }
}

resource "aws_security_group" "jenkins_sg" {
  name        = "${local.name}-jenkins-sg"
  description = "Security group for jenkins server"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr_blocks]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr_blocks]
  }

    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr_blocks]
  }

  # ingress {
  #   description     = "Allow sonar to access jenkins for quality gates result"
  #   from_port       = 80
  #   to_port         = 80
  #   protocol        = "tcp"
  #   security_groups = [aws_security_group.sonar_sg.id]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, { Name = "${local.name}-jenkins-sg" })
}

resource "aws_security_group" "nexus_sg" {
  name        = "${local.name}-nexus-sg"
  vpc_id      = var.vpc_id
  description = "Security group for nexus server"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr_blocks]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr_blocks]
  }

   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr_blocks]
  }

  ingress {
    description     = "Allow Jenkins to upload artifacts"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]
  }


  egress {
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, { Name = "${local.name}-nexus-sg" })
}

resource "aws_security_group" "sonar_sg" {
  name        = "${local.name}-app-sg"
  vpc_id      = var.vpc_id
  description = "Security group for sonarqube server"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr_blocks]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr_blocks]
  }
  ingress {
    description     = "Allow Jenkins to upload sonar server reports"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]
  }


  egress {
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, { Name = "${local.name}-sonar-sg" })
}





