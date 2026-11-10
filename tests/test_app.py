import pytest
from app import app


@pytest.fixture
def client(monkeypatch):
    monkeypatch.delenv("FAIL_MODE", raising=False)
    app.config["TESTING"] = True
    return app.test_client()


def test_index(client):
    assert client.get("/").text == "DevOps Mini Lab"


def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json == {"status": "healthy"}


def test_tasks(client):
    assert client.get("/tasks").json == {"tasks": ["Build", "Test", "Deploy"]}


def test_metrics(client):
    client.get("/")
    text = client.get("/metrics").text
    assert 'lab_http_requests_total{endpoint="/",method="GET",status="200"}' in text
    assert "lab_uptime_seconds" in text
    assert "lab_health 1.0" in text


def test_failure_metrics(client, monkeypatch):
    before = float(next(line.split()[1] for line in client.get("/metrics").text.splitlines() if line.startswith("lab_errors_total ")))
    monkeypatch.setenv("FAIL_MODE", "true")
    assert client.get("/").status_code == 500
    assert client.get("/health").status_code == 503
    metrics = client.get("/metrics").text
    assert "lab_health 0.0" in metrics
    assert 'status="500"' in metrics
    after = float(next(line.split()[1] for line in metrics.splitlines() if line.startswith("lab_errors_total ")))
    assert after == before + 2


def test_environment_message(client, monkeypatch):
    monkeypatch.setenv("APP_MESSAGE", "Training")
    assert client.get("/").text == "Training"
