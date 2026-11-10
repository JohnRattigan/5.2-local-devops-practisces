#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
[ -s .local/kubeconfig ] || { echo 'Run setup.sh first' >&2; exit 1; }
cp .local/kubeconfig .local/jenkins-kubeconfig
chmod 600 .local/jenkins-kubeconfig
# Jenkins joins the k3d Docker network and uses the server's internal TLS endpoint.
kubectl --kubeconfig .local/jenkins-kubeconfig config set-cluster k3d-devops-mini-lab --server=https://k3d-devops-mini-lab-server-0:6443
docker compose -p devops-mini-lab -f jenkins/compose.yml up -d --build
