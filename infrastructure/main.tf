terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "~> 4.0"
    }
  }
}

# Authenticate via the existing linode-cli config file.
# The profile name is supplied via TF_VAR_linode_config_profile or terraform.tfvars.
provider "linode" {
  config_path    = pathexpand("~/.config/linode-cli")
  config_profile = var.linode_config_profile
}

resource "linode_lke_cluster" "friendly_parakeet" {
  label       = "friendly-parakeet"
  k8s_version = "1.36"
  region      = "se-sto"
  tags        = ["friendly-parakeet"]

  pool {
    type  = "g6-standard-2"
    count = 3
  }
}

output "kubeconfig" {
  description = "Base64-encoded kubeconfig for the cluster"
  value       = linode_lke_cluster.friendly_parakeet.kubeconfig
  sensitive   = true
}

output "api_endpoints" {
  description = "Kubernetes API server endpoints"
  value       = linode_lke_cluster.friendly_parakeet.api_endpoints
}

output "cluster_id" {
  description = "The LKE cluster ID"
  value       = linode_lke_cluster.friendly_parakeet.id
}

output "cluster_status" {
  description = "The cluster status"
  value       = linode_lke_cluster.friendly_parakeet.status
}
