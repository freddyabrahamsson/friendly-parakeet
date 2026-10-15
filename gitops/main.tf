terraform {
  required_version = ">= 1.11.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}

# The cluster is provisioned by the ../infrastructure root module. Read its
# outputs from the local state so this root can connect without extra setup.
data "terraform_remote_state" "infrastructure" {
  backend = "local"

  config = {
    path = "${path.module}/../infrastructure/terraform.tfstate"
  }
}

locals {
  kubeconfig   = yamldecode(base64decode(data.terraform_remote_state.infrastructure.outputs.kubeconfig))
  kube_cluster = local.kubeconfig.clusters[0].cluster
  kube_user    = local.kubeconfig.users[0].user
}

locals {
  has_git_token  = var.git_token != ""
  has_github_app = var.github_app_id != ""
  git_auth_secret = local.has_git_token || local.has_github_app ? yamlencode({
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name = "flux-system"
    }
    type = "Opaque"
    stringData = merge(
      local.has_git_token ? {
        username = "git"
        password = var.git_token
      } : {},
      local.has_github_app ? {
        githubAppID                = var.github_app_id
        githubAppInstallationOwner = var.github_app_installation_owner
        githubAppPrivateKey        = var.github_app_pem
      } : {},
    )
  }) : ""
}

module "flux_operator_bootstrap" {
  source = "controlplaneio-fluxcd/flux-operator-bootstrap/kubernetes"

  revision = var.bootstrap_revision

  gitops_resources = {
    instance_yaml = file("${path.root}/../clusters/${var.cluster_name}/flux-system/flux-instance.yaml")
    operator_chart = {
      values_yaml = file("${path.root}/../clusters/${var.cluster_name}/flux-system/flux-operator-values.yaml")
    }
  }

  managed_resources = {
    secrets_yaml = local.git_auth_secret
    runtime_info = {
      labels = {
        "reconcile.fluxcd.io/watch" = "Enabled"
      }
      data = {
        CLUSTER_REGION = var.cluster_region
      }
    }
  }
}

output "kubeconfig" {
  description = "Base64-encoded kubeconfig for the cluster"
  value       = data.terraform_remote_state.infrastructure.outputs.kubeconfig
  sensitive   = true
}
