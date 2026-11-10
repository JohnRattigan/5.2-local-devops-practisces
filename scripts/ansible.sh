#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
export ANSIBLE_HOME="$PWD/.local/ansible"
export ANSIBLE_COLLECTIONS_PATH="$PWD/.local/collections"
export PATH="$PWD/.venv/bin:$PATH"
cd ansible
exec ansible-playbook playbook.yml "$@"
