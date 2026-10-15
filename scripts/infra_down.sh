#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../infrastructure"

# Verify the Linode profile is configured — either via env var or terraform.tfvars
if [[ -z "${TF_VAR_linode_config_profile:-}" ]] && [[ ! -f terraform.tfvars ]]; then
  echo "Error: linode_config_profile is not set." >&2
  echo "  Either export TF_VAR_linode_config_profile=<your-profile>" >&2
  echo "  or create infrastructure/terraform.tfvars with: linode_config_profile = \"<your-profile>\"" >&2
  exit 1
fi

echo "==> Destroying infrastructure..."
tofu destroy -auto-approve

if [[ -f kubeconfig.yaml ]]; then
  rm kubeconfig.yaml
  echo "==> Removed local kubeconfig.yaml"
fi

echo "==> Done. All Linode resources managed by this config have been destroyed."
