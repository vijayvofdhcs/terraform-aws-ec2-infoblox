terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8.0"
    }
    infoblox = {
      source  = "infobloxopen/infoblox"
      version = "2.1.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "infoblox" {

  #   add the following environment variables:

  #   export INFOBLOX_USERNAME=”admin”
  #   export INFOBLOX_PASSWORD=”password”
  #   export INFOBLOX_SERVER=”10.0.0.1”

}


data "aws_ami" "ubuntu" {
  count = var.ami_id == null ? 1 : 0

  owners      = ["099720109477", "513442679011"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "ubuntu" {

  ami                    = data.aws_ami.ubuntu[0].id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids
  vpc_security_group_ids = [aws_security_group.ubuntu[0].id]
  ssh_key_pair_name      = var.ssh_key_pair_name
  # associate_public_ip_address = "true"

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = merge(
    { Name = "${var.friendly_name_prefix}-tfc-ubuntu" },
    var.common_tags
  )
}

resource "aws_security_group" "ubuntu" {

  name   = "${var.friendly_name_prefix}-sg-ubuntu-allow"
  vpc_id = var.vpc_id

  tags = merge(
    { Name = "${var.friendly_name_prefix}-sg-ubuntu-allow" },
    var.common_tags
  )
}

resource "aws_security_group_rule" "ubuntu_ingress_ssh" {

  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.ubuntu_ingress_cidr_allow
  description = "Allow SSH to ubuntu instance"

  security_group_id = aws_security_group.ubuntu[0].id
}

resource "aws_security_group_rule" "ubuntu_egress" {

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow all egress traffic from ubuntu instance"

  security_group_id = aws_security_group.ubuntu[0].id
}

resource "infoblox_a_record" "ubuntu" {

  fqdn    = "${var.friendly_name_prefix}.dhcs.ca.gov"
  ip_addr = aws_instance.ubuntu.*.private_ip

  ttl = 3600 # ttl=0 means 'do not cache'

  #   dns_view = "non_default_dnsview" # corresponding DNS view MUST exist
}
