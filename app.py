import logging
import os
import time

from flask import Flask, jsonify, request
from prometheus_client import Counter, Gauge, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
STARTED = time.time()
REQUESTS = Counter("lab_http_requests", "HTTP responses", ["method", "endpoint", "status"])
ERRORS = Counter("lab_errors", "HTTP server errors")
UPTIME = Gauge("lab_uptime_seconds", "Seconds since application start")
HEALTH = Gauge("lab_health", "Application health: 1 healthy, 0 simulated failure")


@app.after_request
def observe(response):
    REQUESTS.labels(request.method, request.url_rule.rule if request.url_rule else "unmatched", str(response.status_code)).inc()
    if response.status_code >= 500:
        ERRORS.inc()
    app.logger.info("%s %s %s", request.method, request.path, response.status_code)
    return response


@app.get("/")
def index():
    if os.getenv("FAIL_MODE", "false").lower() == "true":
        return jsonify(error="Deliberate lab failure"), 500
    return os.getenv("APP_MESSAGE", "DevOps Mini Lab")


@app.get("/health")
def health():
    failed = os.getenv("FAIL_MODE", "false").lower() == "true"
    return jsonify(status="unhealthy" if failed else "healthy"), 503 if failed else 200


@app.get("/tasks")
def tasks():
    return jsonify(tasks=["Build", "Test", "Deploy"])


@app.get("/metrics")
def metrics():
    UPTIME.set(time.time() - STARTED)
    HEALTH.set(0 if os.getenv("FAIL_MODE", "false").lower() == "true" else 1)
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "8000")))
