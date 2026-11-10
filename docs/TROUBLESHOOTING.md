# Troubleshooting

Run commands from repository root. Keep Docker Desktop running and export
`KUBECONFIG="$PWD/.local/kubeconfig"`. Diagnose the first failing command; do not
reset your entire Docker installation or delete unrelated resources.

| Symptom | Diagnosis and resolution |
|---|---|
| Docker unavailable | `docker info`, start Docker Desktop, select the correct context. Terraform uses its own socket input; set TF_VAR_docker_host as in README. |
| Terraform context/socket mismatch | Use `docker context inspect`; `docker_host` must point at the same daemon used by k3d and Ansible. |
| Terraform state mixing | Always `scripts/tf.sh dev ...` or `prod ...`; inspect the two `.local/terraform` paths. Never copy state across them or apply from `terraform/`. |
| Existing Docker resource name | Inspect ownership first. Import the intended resource into the right state; do not delete someone else's resource to free the name. |
| Provider download or checksum error | Check network and trusted provider registry, rerun init after fixing trust/access. Never disable checksum verification or edit a checksum to force success. |
| Port 6550/8000/8080/9090/3000 busy | Stop only your old port-forward/container. Choose another host-side port where needed; changing cluster API port requires updating setup and regenerating kubeconfigs. |
| Cluster exists but stopped | `k3d cluster list`, `k3d cluster start devops-mini-lab`. Setup reuses the named cluster; it does not silently recreate it. |
| k3d restarts before readiness | Inspect `docker logs k3d-devops-mini-lab-server-0` and its `/var/log/k3d-entrypoints_*.log`. Nested runtimes may deny `/sys/fs/cgroup/init`; this is a runtime capability blocker. Test on Docker Desktop; do not bypass cgroup permissions. |
| Pending/OOMKilled pods | `kubectl describe pod`, events and Docker Desktop resource allocation. Give the small lab enough memory/CPU before retrying. |
| ImagePullBackOff | Import the exact tag with `k3d image import devops-mini-lab:TAG -c devops-mini-lab`; imagePullPolicy is IfNotPresent. Check rollout image and undo deliberate bad-image exercises. |
| Probe failures after FAIL_MODE exercise | `kubectl set env deployment/app FAIL_MODE- -n devops-mini-lab`, rollout status, then smoke test. Old healthy replicas can hide a failed new replica from Service requests. |
| Stale images with reused tags | deploy.sh restarts the Deployment after import. Prefer unique tags (Jenkins uses BUILD_NUMBER). |
| Ansible cannot find Docker plugin | Install requirements.yml into `.local/collections`; wrapper exports the collection path. Docker CLI must be on PATH; no SSH key is used. |
| Python/Ansible mismatch | Use a Python 3.12 controller virtualenv; recreate only `.venv` if it was built with a different version. Jenkins installs test dependencies separately and does not run Ansible. |
| Ansible bootstrap apt failure | Raw task installs Python first. Check container DNS and package mirrors; apt needs access from INSIDE the Ubuntu container. Docker API-created containers do not inherit Docker CLI proxy defaults. Supply approved proxy/trust through local container configuration when your network requires it. |
| Galaxy 403 | Allow the required Galaxy domains via environment settings, or install the pinned collection from its official release source. Never disable TLS or signatures. The cloud validation used official GitHub collection source for the Docker connection plugin. |
| Ansible remains changed | Cache refresh can change after an hour. Templates/packages/users should converge; inspect which task changes. `-e lab_message=...` intentionally triggers restart. No systemd is used. |
| Vault decryption fails | Dummy example password is `lab-only`. Use --ask-vault-pass; never use a real secret with this public password. |
| Jenkins plugin not found | Complete wizard and install Pipeline, Git, JUnit, Timestamper before creating the SCM job. This is manual setup, not bundled job provisioning. |
| Jenkins cannot access cluster | Re-run jenkins.sh after cluster recreation; confirm external Docker network and kubeconfig mount. Do not replace TLS verification with insecure settings. |
| Jenkins cannot build Docker | Check socket bind and installed Docker/buildx tools. The lab controller intentionally runs as root; keep it isolated and use only trusted repositories. |
| Jenkins SCM sees old code | Commit/push your changes yourself; job checkout reads its configured remote branch, not this workspace. |
| Prometheus no data | Check app readiness, target `app:8000`, Service selectors, Prometheus Targets page, and wait a minute for rate samples. `up=0` means a scrape failed, not necessarily a measured application error. |
| Grafana dashboard missing | Check rollout and provisioning logs; resources.yml embeds the four source files. Update matching embedded ConfigMap content when changing source files; contract tests check consistency. Restart monitoring Deployments to load updated ConfigMap subPath files. |
| Empty logs or reset metrics | Logs and time series are ephemeral. A new app process resets counters; no Loki/ELK or durable monitoring volume is included. |
| Cleanup fails | Fix the exact daemon/cluster/state problem and rerun. It intentionally stops rather than silently declaring resources removed. Data volume and image retention is deliberate. |

On a managed TLS-proxy environment, the application and Jenkins Dockerfiles accept
an optional BuildKit `proxy_ca` secret. Example: `docker build --secret
id=proxy_ca,src=/etc/ssl/certs/ca-certificates.crt -t devops-mini-lab:local .`.
This mounts public trust during dependency installation without storing a private
credential or disabling verification. On normal Docker Desktop, `docker build`
needs no secret. For builds inside Jenkins behind a corporate proxy, configure
trusted CA and proxy routing in the Jenkins environment before running jobs.
Do not copy cloud-session credentials into repository files.
