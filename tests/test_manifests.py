"""Offline integration contracts; runtime Kubernetes checks remain separate."""
from pathlib import Path
import json
import yaml

ROOT = Path(__file__).resolve().parents[1]


def test_service_and_deployment_contract():
    deployment = yaml.safe_load((ROOT / "k8s/deployment.yml").read_text())
    service = yaml.safe_load((ROOT / "k8s/service.yml").read_text())
    pod = deployment["spec"]["template"]
    assert service["spec"]["selector"] == pod["metadata"]["labels"]
    container = pod["spec"]["containers"][0]
    assert service["spec"]["ports"][0]["targetPort"] == container["ports"][0]["name"]
    assert container["readinessProbe"]["httpGet"]["path"] == "/health"
    assert pod["spec"]["securityContext"]["runAsNonRoot"] is True


def test_monitoring_provisioning_matches_sources():
    docs = list(yaml.safe_load_all((ROOT / "monitoring/resources.yml").read_text()))
    config = docs[0]["data"]
    for key, filename in [("prometheus.yml", "prometheus.yml"), ("datasource.yml", "grafana-datasource.yml"), ("dashboards.yml", "grafana-dashboards.yml")]:
        assert yaml.safe_load(config[key]) == yaml.safe_load((ROOT / "monitoring" / filename).read_text())
    assert json.loads(config["dashboard.json"]) == json.loads((ROOT / "monitoring/dashboard.json").read_text())
    assert yaml.safe_load(config["prometheus.yml"])["scrape_configs"][0]["static_configs"][0]["targets"] == ["app:8000"]
