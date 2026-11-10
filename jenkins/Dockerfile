# syntax=docker/dockerfile:1
FROM docker:27.5.1-cli AS dockercli
FROM jenkins/jenkins:lts-jdk21@sha256:74401de6a6f92e1afe1b02d1c8e3d0c33f263bfb5275dd8813f9150355f2367b
USER root
COPY --from=dockercli /usr/local/bin/docker /usr/local/bin/docker
COPY --from=dockercli /usr/local/libexec/docker/cli-plugins /usr/local/libexec/docker/cli-plugins
ARG TARGETARCH
RUN --mount=type=secret,id=proxy_ca \
    if [ -f /run/secrets/proxy_ca ]; then cp /run/secrets/proxy_ca /usr/local/share/ca-certificates/lab-build-proxy.crt; update-ca-certificates; fi; \
    apt-get update && apt-get install -y --no-install-recommends python3 python3-venv curl ca-certificates git && \
    arch="${TARGETARCH:-$(dpkg --print-architecture)}" && \
    curl -fsSLo /tmp/kubectl "https://dl.k8s.io/release/v1.31.5/bin/linux/$arch/kubectl" && \
    curl -fsSLo /tmp/kubectl.sha256 "https://dl.k8s.io/release/v1.31.5/bin/linux/$arch/kubectl.sha256" && \
    cd /tmp && echo "$(cat kubectl.sha256)  kubectl" | sha256sum -c - && \
    install -m 0755 kubectl /usr/local/bin/kubectl && \
    rm -rf /var/lib/apt/lists/* /tmp/kubectl* && \
    rm -f /usr/local/share/ca-certificates/lab-build-proxy.crt && update-ca-certificates
# Deliberately root to access Docker Desktop's socket in this isolated lab.
