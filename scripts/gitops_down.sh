#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../gitops"

echo "==> Extracting kubeconfig..."
tofu output -raw kubeconfig | base64 -d > kubeconfig.yaml
export KUBECONFIG="$(pwd)/kubeconfig.yaml"

echo "==> Destroying Flux Operator bootstrap..."
tofu destroy -auto-approve

if command -v flux-operator >/dev/null 2>&1; then
  echo "==> Uninstalling Flux Operator and Flux instance..."
  flux-operator -n flux-system uninstall --keep-namespace
else
  echo "==> flux-operator CLI not found, skipping uninstall."
  echo "    Remove Flux manually with: flux-operator -n flux-system uninstall --keep-namespace"
fi

rm -f kubeconfig.yaml

echo "==> Done. Flux is removed; the cluster itself is untouched."
echo "    To destroy the cluster, run scripts/infra_down.sh"
