variable "friendly_name_prefix" {
  type        = string
  description = "Friendly name prefix used for tagging and naming AWS resources."
}

variable "common_tags" {
  type        = map(string)
  description = "Map of common tags for all taggable AWS resources."
  default     = {}
}

variable "ami_id" {
  type        = string
  description = "Custom AMI ID for Launch Template."
  default     = null

  validation {
    condition     = try((length(var.ami_id) > 4 && substr(var.ami_id, 0, 4) == "ami-"), var.ami_id == null)
    error_message = "The vale of `ami_id` must start with \"ami-\"."
  }
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type/size."
  default     = "t2.micro"
}

variable "vpc_id" {
  type        = string
  description = "ID of VPC for Security Group."
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of Subnet IDs to use for EC2 instances."
}

variable "ssh_key_pair_name" {
  type        = string
  description = "Existing SSH key pair to use for instance."
  default     = null
}

variable "ubuntu_ingress_cidr_allow" {
  type        = list(string)
  description = "List of CIDR ranges to allow SSH ingress to ubuntu instance."
  default     = []
}
