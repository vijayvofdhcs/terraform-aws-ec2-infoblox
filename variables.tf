#--------------------------------------------------------------------------------------------------
# Common
#--------------------------------------------------------------------------------------------------
variable "friendly_name_prefix" {
  type        = string
  description = "Friendly name to prefix AWS resource names with."
}

variable "common_tags" {
  type        = map(string)
  description = "Map of common tags for taggable AWS resources."
  default     = {}
}

#--------------------------------------------------------------------------------------------------
# Networking
#--------------------------------------------------------------------------------------------------
variable "vpc_id" {
  type        = string
  description = "ID of VPC for Security Group."
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of Subnet IDs to use for EC2 instances."
}

variable "cidr_ingress_ssh_allow" {
  type        = list(string)
  description = "List of source CIDR blocks to allow SSH ingress to EC2 instances."
  default     = []
}

#--------------------------------------------------------------------------------------------------
# Autoscaling Group
#--------------------------------------------------------------------------------------------------
variable "ami_id" {
  type        = string
  description = "Custom AMI ID for Launch Template."
  default     = null

  validation {
    condition     = try((length(var.ami_id) > 4 && substr(var.ami_id, 0, 4) == "ami-"), var.ami_id == null)
    error_message = "The vale of `ami_id` must start with \"ami-\"."
  }
}

variable "instance_size" {
  type        = string
  description = "EC2 instance type for Launch Template."
  default     = "m5.large"
}

variable "instance_count" {
  type        = number
  description = "Desired number of EC2 instances to run in Autoscaling Group."
  default     = 1
}

variable "ssh_key_pair_name" {
  type        = string
  description = "Name of existing SSH key pair to configure for EC2 instances."
  default     = null
}

#--------------------------------------------------------------------------------------------------
# Cloud Agents
#--------------------------------------------------------------------------------------------------
variable "tfc_agent_token" {
  type        = string
  description = "Agent pool token to authenticate to TFC/E when cloud agents are instantiated."
}

variable "tfc_agent_name" {
  type        = string
  description = "Name of agent."
}

variable "tfc_agent_version" {
  type        = string
  description = "Version of tfc-agent to run."
  default     = "1.2.0"
}

variable "tfc_address" {
  type        = string
  description = "Hostname of self-hosted TFE instance. Leave default for TFC."
  default     = "app.terraform.io"
}

variable "number_of_agents" {
  type        = number
  description = "Number of cloud agents to run per instance."
  default     = 1
}