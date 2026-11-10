#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
TAG=${1:-local}
case "$TAG" in *[!a-zA-Z0-9_.-]*|'') echo 'Invalid image tag' >&2; exit 2;; esac
export KUBECONFIG="$PWD/.local/kubeconfig"
[ -s "$KUBECONFIG" ] || { echo 'Run setup.sh first' >&2; exit 1; }
docker build -t "devops-mini-lab:$TAG" .
k3d image import "devops-mini-lab:$TAG" -c devops-mini-lab
kubectl apply -f k8s/namespace.yml
kubectl apply -f k8s/
kubectl -n devops-mini-lab set image deployment/app app="devops-mini-lab:$TAG"
# Repeated local builds reuse a tag; explicitly restart to use the newly imported image.
kubectl -n devops-mini-lab rollout restart deployment/app
kubectl -n devops-mini-lab rollout status deployment/app --timeout=180s
scripts/smoke.sh
