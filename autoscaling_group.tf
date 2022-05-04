#--------------------------------------------------------------------------------------------------
# Ubuntu AMI
#--------------------------------------------------------------------------------------------------
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

#--------------------------------------------------------------------------------------------------
# Launch Template
#--------------------------------------------------------------------------------------------------
locals {
  user_data_args = {
    tfc_agent_token   = var.tfc_agent_token
    tfc_agent_name    = var.tfc_agent_name
    tfc_agent_version = var.tfc_agent_version
    tfc_address       = var.tfc_address
    number_of_agents  = var.number_of_agents
  }
}

resource "aws_launch_template" "agents" {
  name                                 = "${var.friendly_name_prefix}-cloud-agents-template"
  update_default_version               = true
  image_id                             = var.ami_id == null ? data.aws_ami.ubuntu[0].id : var.ami_id
  instance_type                        = var.instance_size
  key_name                             = var.ssh_key_pair_name
  user_data                            = base64encode(templatefile("${path.module}/templates/user_data.sh.tpl", local.user_data_args))
  instance_initiated_shutdown_behavior = "terminate"

  vpc_security_group_ids = [
    aws_security_group.agents.id
  ]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type = "gp2"
      volume_size = 20
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      { "Name" = "${var.friendly_name_prefix}-cloud-agents-host" },
      { "Type" = "autoscaling-group" },
      var.common_tags
    )
  }

  tags = merge(
    { "Name" = "${var.friendly_name_prefix}-cloud-agents-template" },
    var.common_tags
  )
}

#--------------------------------------------------------------------------------------------------
# Autoscaling Group
#--------------------------------------------------------------------------------------------------
resource "aws_autoscaling_group" "agents" {
  name                = "${var.friendly_name_prefix}-cloud-agents-asg"
  min_size            = 0
  max_size            = var.instance_count
  desired_capacity    = var.instance_count
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.agents.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.friendly_name_prefix}-cloud-agents-asg"
    propagate_at_launch = false
  }

  dynamic "tag" {
    for_each = var.common_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = false
    }
  }
}