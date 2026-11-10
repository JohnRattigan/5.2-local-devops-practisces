#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Exact names and local state only: never prune the user's Docker daemon.
if [ -s .local/kubeconfig ]; then
  KUBECONFIG="$PWD/.local/kubeconfig" kubectl delete namespace devops-mini-lab --ignore-not-found || exit 1
fi
k3d cluster delete devops-mini-lab
docker compose -p devops-mini-lab -f jenkins/compose.yml down
for environment in dev prod; do
  if [ -f ".local/terraform/$environment/terraform.tfstate" ]; then
    scripts/tf.sh "$environment" destroy -auto-approve
  fi
done
# Keep Jenkins data, Terraform state backups, images and reports for evidence.
