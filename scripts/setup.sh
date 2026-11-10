#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
for tool in docker terraform k3d kubectl python3; do
  command -v "$tool" >/dev/null || { echo "Missing $tool; see README.md" >&2; exit 1; }
done
docker info >/dev/null
docker compose version
python3 -m venv .venv
.venv/bin/pip install -r requirements-dev.txt
export ANSIBLE_HOME="$PWD/.local/ansible"
export ANSIBLE_COLLECTIONS_PATH="$PWD/.local/collections"
.venv/bin/ansible-galaxy collection install -r ansible/requirements.yml -p "$ANSIBLE_COLLECTIONS_PATH"
scripts/test.sh
scripts/tf.sh dev init -input=false
scripts/tf.sh dev validate
if ! k3d cluster list -o json | .venv/bin/python -c 'import json,sys; sys.exit(not any(c["name"]=="devops-mini-lab" for c in json.load(sys.stdin)))'; then
  k3d cluster create devops-mini-lab --image rancher/k3s:v1.31.5-k3s1 --kubeconfig-update-default=false --agents 0 --api-port 127.0.0.1:6550 --k3s-arg '--disable=traefik@server:0' --wait
fi
mkdir -p .local
k3d kubeconfig get devops-mini-lab > .local/kubeconfig
chmod 600 .local/kubeconfig
scripts/deploy.sh local
scripts/tf.sh dev apply -auto-approve -input=false
# This password protects only the committed, explicitly dummy Vault example.
printf 'lab-only\n' > .local/vault-password
chmod 600 .local/vault-password
scripts/ansible.sh --vault-password-file "$PWD/.local/vault-password"
rm .local/vault-password
scripts/monitoring.sh
printf 'Lab deployed. Start Jenkins using README.md.\n'
