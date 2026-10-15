# Set this via TF_VAR_linode_config_profile or a terraform.tfvars file (gitignored).
# Find your profile name in ~/.config/linode-cli — it's the [section] header.
variable "linode_config_profile" {
  description = "Linode CLI config profile name from ~/.config/linode-cli"
  type        = string
}
