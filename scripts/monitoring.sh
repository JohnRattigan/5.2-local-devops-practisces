#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
export KUBECONFIG="$PWD/.local/kubeconfig"
if ! kubectl -n devops-mini-lab get secret grafana-admin >/dev/null 2>&1; then
  # Random local administrator credential; never printed or committed.
  .venv/bin/python -c 'import secrets,sys; sys.stdout.write(secrets.token_urlsafe(32))' > .local/grafana-password
  chmod 600 .local/grafana-password
  kubectl -n devops-mini-lab create secret generic grafana-admin --from-file=password=.local/grafana-password
  rm .local/grafana-password
fi
kubectl apply -f monitoring/resources.yml
for service in prometheus grafana; do
  kubectl -n devops-mini-lab rollout status deployment/"$service" --timeout=180s
done
