provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs                 = data.aws_availability_zones.available.names
  public_subnets      = var.public_subnets
  public_subnet_names = var.public_subnet_names

  public_subnet_tags = {
    subnet                   = "public"
    "kubernetes.io/role/elb" = "1"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "ansible_bastion_sg" {
  vpc_id      = module.vpc.vpc_id
  name        = "bastion-sg"
  description = "Allow SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks_ingress_bastion
    description = "Allow SSH from trusted IPs"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr_blocks_egress
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "bastion-sg"
  }
}

resource "aws_instance" "bastion" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.public_subnets[0]
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ansible_bastion_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y software-properties-common git vim
              add-apt-repository --yes --update ppa:ansible/ansible
              apt install -y ansible >> /var/log/ansible-install.log 2>&1
              echo "Ansible installed successfully" >> /var/log/ansible-install.log
              git clone git@github.com:thani2808/java_with_ansible_1205.git /opt/ansible-playbooks
              echo "Git repo cloned successfully" >> /var/log/ansible-install.log
              EOF

  tags = {
    Name        = "Bastion"
    Environment = "dev"
  }
}