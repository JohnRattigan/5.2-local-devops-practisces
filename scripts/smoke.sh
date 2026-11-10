#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
export KUBECONFIG=${KUBECONFIG:-$PWD/.local/kubeconfig}
POD=$(kubectl -n devops-mini-lab get pods -l app=mini-lab --field-selector=status.phase=Running -o jsonpath='{.items[0].metadata.name}')
kubectl -n devops-mini-lab exec "$POD" -- python -c 'import json,urllib.request; u="http://127.0.0.1:8000"; assert urllib.request.urlopen(u).read()==b"DevOps Mini Lab"; assert json.load(urllib.request.urlopen(u+"/health"))["status"]=="healthy"; assert len(json.load(urllib.request.urlopen(u+"/tasks"))["tasks"])==3; assert b"lab_http_requests_total" in urllib.request.urlopen(u+"/metrics").read(); print("Kubernetes endpoint smoke test passed")'
