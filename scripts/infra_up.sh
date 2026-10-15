#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../infrastructure"

# Verify the Linode profile is configured — either via env var or terraform.tfvars
if [[ -z "${TF_VAR_linode_config_profile:-}" ]] && [[ ! -f terraform.tfvars ]]; then
  echo "Error: linode_config_profile is not set." >&2
  echo "  Either export TF_VAR_linode_config_profile=<your-profile>" >&2
  echo "  or create infrastructure/terraform.tfvars with: linode_config_profile = \"<your-profile>\"" >&2
  echo "  (find your profile name in ~/.config/linode-cli — it's the [section] header)" >&2
  exit 1
fi

echo "==> Initializing OpenTofu..."
tofu init

echo "==> Applying infrastructure..."
tofu apply -auto-approve

echo "==> Extracting kubeconfig..."
tofu output -raw kubeconfig | base64 -d > kubeconfig.yaml

echo ""
echo "Cluster is up. To connect:"
echo "  export KUBECONFIG=$(pwd)/kubeconfig.yaml"
echo "  kubectl get nodes"
