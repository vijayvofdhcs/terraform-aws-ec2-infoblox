terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.12.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "agents" {
  source = "../.."

  friendly_name_prefix = var.friendly_name_prefix
  common_tags          = var.common_tags

  vpc_id                 = var.vpc_id
  subnet_ids             = var.subnet_ids
  cidr_ingress_ssh_allow = var.cidr_ingress_ssh_allow
  ssh_key_pair_name      = var.ssh_key_pair_name

  tfc_agent_token  = var.tfc_agent_token
  tfc_agent_name   = var.tfc_agent_name
  number_of_agents = var.number_of_agents
}