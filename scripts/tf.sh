#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
ENVIRONMENT=${1:?Usage: tf.sh dev|prod terraform-command [arguments]}
shift
case "$ENVIRONMENT" in dev|prod) ;; *) echo 'Use dev or prod' >&2; exit 2;; esac
COMMAND=${1:?Missing Terraform command}; shift
WORK="$ROOT/.local/terraform/$ENVIRONMENT"
mkdir -p "$WORK"
# Refresh source only; never copy state or provider caches across environments.
cp "$ROOT"/terraform/*.tf "$WORK/"
mkdir -p "$WORK/modules/linux"
cp "$ROOT"/terraform/modules/linux/*.tf "$WORK/modules/linux/"
if [ -f "$ROOT/terraform/.terraform.lock.hcl" ]; then cp "$ROOT/terraform/.terraform.lock.hcl" "$WORK/"; fi
export TF_IN_AUTOMATION=1
case "$COMMAND" in
  plan|apply|destroy|import) exec terraform -chdir="$WORK" "$COMMAND" -var-file="$ROOT/terraform/environments/$ENVIRONMENT.tfvars" "$@" ;;
  *) exec terraform -chdir="$WORK" "$COMMAND" "$@" ;;
esac
