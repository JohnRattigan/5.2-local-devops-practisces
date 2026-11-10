# Criteria mapping

No awarding-body rubric or criterion IDs were supplied. This table maps every
requested subject to implementation and evidence, without inventing official
apprenticeship codes. Map these rows to your assessor's rubric separately.
All commands below are expanded in [EVIDENCE.md](EVIDENCE.md). Screenshots must
come from your execution; see [VALIDATION.md](VALIDATION.md) for what was tested here.

| Requested criterion | Project files | Demonstration / suggested screenshot |
|---|---|---|
| Small Flask app; root, health and three static tasks | `app.py`, `tests/test_app.py` | Four endpoint curl responses; six endpoint tests |
| Prometheus metrics; uptime, health, request and error counters | `app.py` | `/metrics`, dashboard, deliberate 500/503 and direct metrics |
| Environment variables; no database/frontend | `app.py`, `k8s/configmap.yml` | APP_MESSAGE override; FAIL_MODE recovery |
| Pinned dependencies and pytest | `requirements*.txt`, `scripts/test.sh` | Eight tests and JUnit artifact |
| Small image, non-root user, health check | `Dockerfile`, `.dockerignore` | Build, image inspect user 10001 and healthy status |
| Docker build, tag, run, list, inspect, logs | `Dockerfile` | Docker lifecycle commands and outputs |
| Docker stop, restart, remove, pull and unused image cleanup | `docs/EVIDENCE.md` | Named container lifecycle; inspect dangling images before optional prune |
| Optional authenticated registry push | `docs/EVIDENCE.md` | Your own registry tag/push; credentials required, not needed locally |
| Terraform local network and Ubuntu container | `terraform/modules/linux/main.tf` | Apply creates three resources; Docker list |
| Modules, pinned provider, version constraints | `terraform/versions.tf`, `.terraform.lock.hcl`, `modules/linux/` | Init signature/checksums and module resource addresses |
| Variables, outputs, data sources | `variables.tf`, `outputs.tf`, module registry lookup | Environment inputs, outputs and registry digest read |
| Init, fmt, validate, plan, apply, state list, destroy | `scripts/tf.sh` | Lifecycle command outputs |
| Separate dev/prod tfvars, names and state | `terraform/environments/`, `scripts/tf.sh` | Both containers and two state paths; prod destroy leaves dev |
| Import unmanaged resource | module network plus import runbook | Create Docker network manually, import actual ID, plan |
| State management, sensitive variable and secret practices | `variables.tf`, `.gitignore`, evidence state section | Explain mask vs encryption; ignored state and backups, dummy-only inputs |
| Remote state and locking concepts | `docs/EVIDENCE.md` | Written explanation only; NOT completed shared backend evidence |
| Ansible Docker connection, inventory, config and playbook | `ansible/` | Syntax check, real connection without SSH |
| apt cache, package install and removal | `roles/common/tasks/main.yml` | Curl/supervisor package query; install nano then role removes it |
| Linux user, directory, ownership and permissions | common role | `id`, `stat`, private dummy config mode 0600 |
| Background service without systemd | Supervisor template and handler | HTTP response and supervisor RUNNING status |
| Restart after config change; idempotency | common role, `vars/main.yml` | Changed message fires handler; subsequent unchanged run changed=0 |
| YAML variables, Jinja2 and Vault | `vars/`, `templates/` | Template/variable source, encrypted header, dummy Vault edit |
| Local declarative Jenkins; explicit agent tools | `Jenkinsfile`, `jenkins/Dockerfile`, `compose.yml` | Tool versions in controller, manually configured pipeline |
| Checkout, install, pytest and reports | Jenkinsfile first stages and post | SCM revision, successful tests, archived JUnit report |
| Docker build/tag and local image delivery | Jenkinsfile build/deploy | Build log, build-number tag, containerd import |
| Kubernetes deploy/update and health verification | Jenkinsfile, `scripts/smoke.sh` | Rollout and actual in-pod endpoint assertions |
| Failure diagnosis and logs | Jenkinsfile post failure | Deliberate failed test job and Console Output |
| GitHub connection; polling/webhook distinction | README Jenkins section | Manual SCM job, optional polling settings; no public webhook configured |
| Jenkins localhost and socket privilege awareness | Compose and README | Loopback port mapping plus written privilege explanation |
| k3d local cluster; images without registry | setup/deploy scripts | Cluster list, imported image, running Deployment |
| Namespace, Deployment, Service, ConfigMap and placeholder Secret | `k8s/` | Resource list and manifests (do not display real secret values) |
| Requests/limits, probes and non-root security | `k8s/deployment.yml` | Describe pod resources/probes; readiness behavior |
| Create/delete, scale, inspect and logs | evidence Kubernetes commands | Replica change, describe, logs, Service recreation |
| Rolling update and rollback | deploy script and evidence | Rollout history, bad image, undo and successful smoke test |
| Deliberately failing pod troubleshooting | bad-image and FAIL_MODE exercises | ImagePullBackOff/events or HTTP 503; diagnosis and recovery |
| Prometheus/Grafana minimal monitoring | `monitoring/`, `scripts/monitoring.sh` | Scrape target up, five provisioned dashboard panels |
| Application, Docker, Kubernetes and Jenkins logs | app request logging, evidence | Request status log, pod logs, job failure console |
| Mac localhost, Apple Silicon practicality, no paid services | README, scripts and multiarch images | Local Mac verification still needed; no cloud resources declared |
| Safe repeatable setup/test/cleanup | `scripts/` | Tests, second Ansible run, state-separated lifecycle and named cleanup |
| Honest evidence and limitations | this file, validation and troubleshooting | Your dated screenshots plus explicit unverified checklist |

Cloud VM provisioning, cloud imports, real multi-engineer locking, organizational
incident response and production access governance cannot be genuinely evidenced
by local Docker resources. This lab supplies practice mechanics, not proof of
those real-world activities.
