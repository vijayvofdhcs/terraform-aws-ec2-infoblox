# terraform-aws-tfc-agents-ec2
Terraform module to deploy EC2 instances within an Autoscaling Group that run one or more Terraform Cloud Agents.

## Usage
```hcl
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
```

> Note: see the [tests/main](./tests/main) directory for an example Terraform configuration to deploy this module.  
> Populate the [terraform.tfvars.example](./tests/main/terraform.tfvars.example) with meaningful values and remove the `.example` extension.
<p>&nbsp;</p>

### Instances
- By default, the marketplace Ubuntu 20.04 image will be used for the EC2 instance(s).
- A custom AMI may be used by specifying a value for the input variable `ami_id`.
- By default, one instance will be deployed within the Autoscaling Group (ASG).
- To change the number of instances to run in the ASG, modify the input variable `instance_count`.
<p>&nbsp;</p>

### Cloud Agents
- The `user_data` script will automatically configure and start a systemd service and target.
- By default, one single agent will be configured _per instance_.
- To change the number of agents to run _per instance_, modify the input variable `number_of_agents`.
- In order for any changes to take effect, `terraform apply` the changes to update the Launch Template, terminate the instance(s), and let the ASG spin up new ones.
<p>&nbsp;</p>
