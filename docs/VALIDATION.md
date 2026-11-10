# Actual validation

Executed in the managed Linux amd64 cloud environment on 10 November 2026.
These results are not Mac screenshots or a completed apprenticeship portfolio.
No paid services, registry push, GitHub write or cloud resources were used.

| Check | Observed result |
|---|---|
| Python project tests | 8 passed: six endpoint/metrics tests and two manifest integration contracts; current JUnit report in ignored `reports/pytest.xml` |
| Tests in Jenkins image | Same 8 passed using the image's Python and a fresh virtualenv; `reports/jenkins-tooling-tests.xml` |
| Flask Docker build | Passed with the cloud's existing CA mounted for pip trust; no verification disabled |
| Live application | Root and health responses checked; Docker reports healthy, configured user 10001:10001 |
| Live failure exercise | Separate Gunicorn container returned 500 at root, 503 at health and exposed lab_health=0 plus error counter |
| Docker tagging/inspection | Temporary evidence tag created, inspected and removed |
| Terraform | 1.11.4 binary checksum verified; provider 3.6.2 signature and checksums validated by init |
| Terraform dev/prod | Init/validate/plan/apply succeeded with independent state paths and distinct running Ubuntu containers; subsequent plans returned no changes |
| Terraform import | Destroyed prod resources, manually created prod network, imported actual network ID, reapplied remaining resources and verified state/clean plan |
| Terraform formatting | Recursive fmt check passed; provider lockfile retained in source |
| Ansible syntax and Vault | Syntax check passed; committed encrypted dummy fixture decrypted to the intended dummy value without printing it |
| Kubernetes manifests | kubeconform 0.6.7 (checksum verified), strict Kubernetes 1.31.5 schema validation: 10 valid resources, 0 invalid/errors/skipped |
| Prometheus | promtool accepted source configuration; live scrape returned up=1 in a temporary shared-loopback Docker test |
| Grafana | API health database=ok; all five dashboard panels provisioned; Grafana datasource API successfully queried Prometheus |
| Jenkins image | Build passed; Java 21, Python 3.13, Docker 27.5.1/buildx and SHA256-verified kubectl 1.31.5 executed |
| Jenkins controller | Started and returned HTTP 200 at login; no plugins, GitHub job or administrator configured automatically |
| Compose and shell | Compose config accepted; all shell scripts passed bash syntax checks |

## Limits and required local follow-up

- **Kubernetes integration is unverified.** k3d creation was attempted. Its server
  restarted before readiness; retained entrypoint logs explicitly reported
  `mkdir: cannot create directory '/sys/fs/cgroup/init': Permission denied`.
  This nested cloud runtime cannot provide the required cgroup access. No
  cluster-dependent smoke test, rollout, scaling, rollback or monitoring rollout
  was claimed successful. Run `scripts/setup.sh` on Docker Desktop.
- **Full Jenkins CI/CD is unverified.** The controller and tools run, but plugin
  installation, SCM checkout credentials and job creation require the README's
  manual steps. The Kubernetes blocker also prevents an end-to-end deployment.
  The image build and tests inside its tooling environment do not prove the
  declarative pipeline executed.
- **The complete setup script has not passed end to end here.** Its components
  were exercised separately because Galaxy access and cluster startup differ
  from normal Docker Desktop. The final startup/deploy scripts need local use.
- **Monitoring test scope:** the cloud Docker network's internal DNS was not
  usable. Temporary, ignored configs replaced Service DNS addresses with
  loopback addresses and containers shared the app's network namespace. This
  verified app metrics, Prometheus scraping, Grafana provisioning and datasource
  integration; it did not validate Kubernetes DNS, Services or ConfigMap mounts.
- Galaxy returned proxy HTTP 403. The pinned community.docker 4.5.2 collection
  was built from its official GitHub tag and installed locally without unused
  inventory-plugin dependencies. Docker connection and remote Python gathering
  executed. Normal Mac setup uses Galaxy and installs declared dependencies.
- Terraform-created Ubuntu containers did not receive Docker CLI proxy defaults.
  For cloud testing only, the existing Docker client proxy was supplied to apt
  in local container configuration. Signed apt metadata and normal checksum
  verification remained enabled. These machine-specific settings are not in Git.
- Mac/Apple Silicon execution, optional registry push, SCM polling/webhooks,
  cloud provisioning/import and actual multi-engineer remote state locking were
  not tested. No credentials were supplied for the optional integrations.

## Ansible runtime results

The common role completed against the Terraform dev container: first full role
run reported `ok=14 changed=8 failed=0`; the unchanged second run reported
`ok=13 changed=0 failed=0`. Changing lab_message invoked the restart handler and
returned the changed HTML over HTTP (`changed=2 failed=0`). Supervisor reported
lab-http RUNNING. Linux checks confirmed the apprentice user, directory mode
0750, content mode 0640 and private dummy configuration mode 0600, all owned by
apprentice. The default message was then restored.


An additional package test installed nano, then the role removed it successfully
(`ok=13 changed=1 failed=0`). The normal YAML message was restored successfully
before teardown.

## Cleanup results

Docker stop/start recovered the live application's health endpoint. Temporary
validation containers were then removed by exact name. `scripts/cleanup.sh`
completed successfully, destroying both Terraform environments and the failed
k3d cluster. A second cleanup run also succeeded with no resources to destroy.
No lab containers or k3d clusters remained. Images, installed tools, local state
backups, ignored diagnostic logs and current JUnit reports were retained. The
temporary dummy Vault password file was removed.

The application source, infrastructure files and documentation are complete, but
the full lab is not running in this cloud instance after teardown. Use README's
Mac instructions to start it and finish the unchecked integrations above.
