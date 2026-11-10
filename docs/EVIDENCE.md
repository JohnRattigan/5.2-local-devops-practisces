# Evidence commands

Run from repository root on your Mac after setup. Export
`KUBECONFIG="$PWD/.local/kubeconfig"` in every terminal. Capture your own command,
output, date and explanation. Never screenshot credentials, unlock passwords,
Vault plaintext, kubeconfigs or Terraform state contents. Capture real failures
and recovery rather than inventing successful logs.

## Application and tests

```bash
./scripts/test.sh
curl -f http://127.0.0.1:8000/
curl -f http://127.0.0.1:8000/health
curl -f http://127.0.0.1:8000/tasks
curl -f http://127.0.0.1:8000/metrics
```

Start the app Service port-forward from README first. Screenshot responses and
pytest summary; keep `reports/pytest.xml` as an artifact.

## Terraform lifecycle, modules, data source and state

```bash
terraform fmt -check -recursive terraform
./scripts/tf.sh dev init
./scripts/tf.sh dev validate
./scripts/tf.sh dev plan
./scripts/tf.sh dev apply
./scripts/tf.sh dev state list
./scripts/tf.sh dev output
./scripts/tf.sh prod init
./scripts/tf.sh prod apply
./scripts/tf.sh prod state list
docker ps --filter name=devops-mini-lab
ls .local/terraform/dev/terraform.tfstate .local/terraform/prod/terraform.tfstate
./scripts/tf.sh prod destroy
```

Screenshot separate names, state paths and plans. State includes module addresses
and `data.docker_registry_image.ubuntu`; its registry digest lookup is a real data
source. Image tags can move: inspect plan before applying a later image update.
Dev/prod are isolated local state files and names, sharing only a retained image.
Use `TF_VAR_dummy_secret=dummy-training-value ./scripts/tf.sh dev plan` to show
variable input, then read `variables.tf` to explain sensitive masking. It is unused
on purpose: do not claim this proves secret encryption. Never add real credentials.

### Import an unmanaged network (resets dev Linux practice)

Finish/capture Linux evidence first. Destroy only the dev Terraform resources;
create a previously unmanaged network, then import its actual ID:

```bash
./scripts/tf.sh dev destroy
# Confirm the network name is free before creating it.
docker network create devops-mini-lab-dev
NETWORK_ID=$(docker network inspect --format '{{.Id}}' devops-mini-lab-dev)
./scripts/tf.sh dev import module.linux.docker_network.lab "$NETWORK_ID"
./scripts/tf.sh dev state list
./scripts/tf.sh dev plan
./scripts/tf.sh dev apply
./scripts/ansible.sh --ask-vault-pass
```

The network now belongs to dev state. Do not remove it behind Terraform's back.
`terraform state list`, outputs, import and plan demonstrate local state management.
Back up state securely before advanced state operations; do not practice `state rm`
on resources you want Terraform to clean up. Local state/plan files are ignored
but can still contain secrets and identifiers; `.gitignore` is not access control.

### Documentation-only remote state concepts

A real shared backend centralizes state, controls access, encrypts storage and can
lock concurrent updates when the selected backend supports locking. For example,
S3 can use a lockfile with an appropriately configured backend. Backend credentials
belong in workload identity/secure settings, not HCL or `-backend-config` files in Git.
This lab uses the local backend only. It does **not** evidence shared remote state,
actual multi-engineer locking, cloud VM provisioning or importing cloud resources.
Importing this Docker network is local import evidence only.

## Ansible and Linux administration

```bash
./scripts/ansible.sh --ask-vault-pass
./scripts/ansible.sh --ask-vault-pass
# Second run: check changed=0, failed=0. Vault password is lab-only.
docker exec devops-mini-lab-dev-linux id apprentice
docker exec devops-mini-lab-dev-linux stat -c '%U %G %a %n' /opt/devops-mini-lab /opt/devops-mini-lab/index.html /home/apprentice/training.conf
docker exec devops-mini-lab-dev-linux dpkg-query -W curl supervisor
docker exec devops-mini-lab-dev-linux sh -c '! dpkg-query -W -f="${Status}" nano 2>/dev/null | grep -q "install ok installed"'
docker exec devops-mini-lab-dev-linux supervisorctl -c /etc/devops-mini-lab-supervisor.conf status
docker exec devops-mini-lab-dev-linux curl -f http://127.0.0.1:8081/
# Package removal actually changes state after deliberately installing nano:
docker exec devops-mini-lab-dev-linux sh -c 'apt-get update && apt-get install -y nano'
./scripts/ansible.sh --ask-vault-pass
# Override a YAML variable and watch the notified restart handler:
./scripts/ansible.sh --ask-vault-pass -e 'lab_message=Changed-by-Ansible'
docker exec devops-mini-lab-dev-linux curl -f http://127.0.0.1:8081/
./scripts/ansible.sh --ask-vault-pass   # restore the YAML default
# Show only the Vault header, not decrypted content:
head -n 1 ansible/vars/vault.yml
```

For a Vault editing demonstration, use `.venv/bin/ansible-vault edit
ansible/vars/vault.yml` and enter `lab-only`; edit only dummy data and restore it
afterwards. `ansible.cfg` selects inventory, `vars/main.yml` provides variables,
Jinja2 renders content and Supervisor configuration. The service runs as apprentice
without systemd and the handler restarts it when a template changes. Inspect root
PID and disk/network processes using `docker exec ... ps` if procps is installed;
`docker stats --no-stream devops-mini-lab-dev-linux` shows container resource use.

## Docker lifecycle

Stop the Kubernetes app port-forward first or use standalone port 8001:

```bash
docker pull python:3.12.10-slim-bookworm
docker build -t devops-mini-lab:local .
docker tag devops-mini-lab:local devops-mini-lab:evidence
docker image inspect devops-mini-lab:evidence
docker run -d --name devops-mini-lab-evidence -p 127.0.0.1:8001:8000 -e APP_MESSAGE='DevOps Mini Lab' devops-mini-lab:evidence
docker ps --filter name=devops-mini-lab-evidence
curl -f http://127.0.0.1:8001/health
docker inspect --format '{{.State.Health.Status}} {{.Config.User}}' devops-mini-lab-evidence
docker logs devops-mini-lab-evidence
docker stop devops-mini-lab-evidence
docker start devops-mini-lab-evidence
docker rm -f devops-mini-lab-evidence
docker image rm devops-mini-lab:evidence
# Optional: removes dangling images globally; inspect and confirm first:
docker image ls --filter dangling=true
docker image prune
```

Optional registry push, only if you have an account and choose to publish the image:

```bash
docker login
export DOCKERHUB_USER=your-own-account
docker tag devops-mini-lab:local "$DOCKERHUB_USER/devops-mini-lab:evidence"
docker push "$DOCKERHUB_USER/devops-mini-lab:evidence"
docker logout
```

No push is needed for the lab. Never put a registry password in a command or file.

## Kubernetes lifecycle and troubleshooting

```bash
kubectl apply -f k8s/
kubectl -n devops-mini-lab get deployments,pods,services,configmaps,secrets
./scripts/deploy.sh evidence-v2
kubectl -n devops-mini-lab rollout history deployment/app
kubectl -n devops-mini-lab scale deployment/app --replicas=2
kubectl -n devops-mini-lab rollout status deployment/app
kubectl -n devops-mini-lab logs deployment/app --all-containers --tail=30
POD=$(kubectl -n devops-mini-lab get pod -l app=mini-lab -o jsonpath='{.items[0].metadata.name}')
kubectl -n devops-mini-lab describe pod "$POD"
# Deliberate broken rollout. The following timeout is an EXPECTED FAILURE:
kubectl -n devops-mini-lab set image deployment/app app=devops-mini-lab:missing
kubectl -n devops-mini-lab rollout status deployment/app --timeout=45s
kubectl -n devops-mini-lab get pods
kubectl -n devops-mini-lab get events --sort-by=.lastTimestamp
kubectl -n devops-mini-lab describe deployment app
kubectl -n devops-mini-lab rollout undo deployment/app
kubectl -n devops-mini-lab rollout status deployment/app --timeout=180s
./scripts/smoke.sh
kubectl -n devops-mini-lab scale deployment/app --replicas=1
# Resource deletion and recreation, with a short intentional outage:
kubectl delete -f k8s/service.yml
kubectl apply -f k8s/service.yml
```

Inspect an actual failing pod with `kubectl describe pod <failing-pod-name>`.
The bad image demonstration should produce ErrImagePull/ImagePullBackOff, not a
passing test. Save both the failure diagnosis and successful rollback.

## Monitoring, logs and a real HTTP failure

```bash
./scripts/monitoring.sh
kubectl -n devops-mini-lab logs deployment/prometheus --tail=30
kubectl -n devops-mini-lab logs deployment/grafana --tail=30
# With Prometheus port-forward running:
curl -fsS 'http://127.0.0.1:9090/api/v1/query?query=up'
# Keep app port-forward active and generate traffic:
for n in 1 2 3 4 5; do curl -fsS http://127.0.0.1:8000/; done
# Deliberate failure overrides ConfigMap until removed:
kubectl -n devops-mini-lab set env deployment/app FAIL_MODE=true
kubectl -n devops-mini-lab get pods -w
```

Cancel the watch after the new pod appears. It becomes unready (503 health) and
may be restarted by its liveness probe. The old pod can remain healthy during the
rolling update; therefore a Service request is not proof of the new pod's failure.
Select the **new** pod by name, then directly exercise it:

```bash
kubectl -n devops-mini-lab exec <new-pod-name> -- python -c 'import urllib.request; urllib.request.urlopen("http://127.0.0.1:8000/")'
# Expected HTTP 500. Metrics remain accessible in the same process:
kubectl -n devops-mini-lab exec <new-pod-name> -- python -c 'import urllib.request; print(urllib.request.urlopen("http://127.0.0.1:8000/metrics").read().decode())'
kubectl -n devops-mini-lab logs <new-pod-name> --tail=50
kubectl -n devops-mini-lab describe pod <new-pod-name>
kubectl -n devops-mini-lab set env deployment/app FAIL_MODE-
kubectl -n devops-mini-lab rollout status deployment/app --timeout=180s
./scripts/smoke.sh
```

Prometheus scrapes the ready Service endpoints, so an unready failing replica may
not appear as `lab_health=0` in the dashboard. Its direct metrics and logs prove
the failure; a missing target is different from a healthy target. To demonstrate
an error metric in a stable scrape target, run the Docker failure exercise below
and inspect its `/metrics` locally. The dashboard shows normal health, process
uptime, request rate and server-error count. Counters reset with process restarts
and different replicas have separate counters. This lab uses one Gunicorn worker
so in-process metrics are consistent; do not increase workers without adapting
Prometheus multiprocess collection.

```bash
docker run -d --name devops-mini-lab-failure -p 127.0.0.1:8002:8000 -e FAIL_MODE=true devops-mini-lab:local
curl -i http://127.0.0.1:8002/          # expected 500
curl -i http://127.0.0.1:8002/health    # expected 503
curl -s http://127.0.0.1:8002/metrics   # error counter and lab_health=0
docker logs devops-mini-lab-failure
docker rm -f devops-mini-lab-failure
```

## Jenkins and Git evidence

Follow README's manual setup and **Build Now**. Screenshot the stage view,
checkout revision, six-or-more tests, image tag, deployment rollout, health check
and archived report. For failure evidence create a temporary branch that changes
an assertion to fail, push it, point a temporary Jenkins job at that branch and
run it manually. Capture the failed test and Console Output, then restore the
normal branch. Do not claim this was done unless you actually ran it.
`docker compose -p devops-mini-lab -f jenkins/compose.yml logs --tail=100 jenkins`
shows controller logs; job Console Output shows stage failures. Optional SCM
polling and private GitHub credentials are separate manual configuration.

## Cleanup evidence

```bash
./scripts/cleanup.sh
docker ps --filter name=devops-mini-lab
k3d cluster list
```

The named resources should be gone; retained images, Jenkins volume and state
backups are intentional. Cloud provider evidence and real organizational
collaboration/security controls require a separate, authorized environment.
