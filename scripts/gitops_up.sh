#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../gitops"

# The gitops root reads the cluster kubeconfig from the infrastructure state
if [[ ! -f ../infrastructure/terraform.tfstate ]]; then
  echo "Error: infrastructure state not found." >&2
  echo "  Run scripts/infra_up.sh first to provision the cluster." >&2
  exit 1
fi

echo "==> Initializing OpenTofu..."
tofu init

echo "==> Installing Flux Operator..."
tofu apply -auto-approve

echo ""
echo "Flux Operator is installed. To verify:"
echo "  export KUBECONFIG=$(pwd)/../infrastructure/kubeconfig.yaml"
echo "  kubectl -n flux-system get pods"
echo "  kubectl -n flux-system get fluxreport/flux -o yaml"
