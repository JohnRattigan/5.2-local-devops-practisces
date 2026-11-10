pipeline {
  agent any
  options { skipDefaultCheckout(true); timestamps(); disableConcurrentBuilds(); timeout(time: 15, unit: 'MINUTES') }
  environment { IMAGE = "devops-mini-lab:${BUILD_NUMBER}" }
  stages {
    stage('Checkout') { steps { checkout scm; sh 'rm -rf reports' } }
    stage('Dependencies') {
      steps { sh 'python3 -m venv .venv && .venv/bin/pip install -r requirements-test.txt' }
    }
    stage('Test') { steps { sh 'scripts/test.sh' } }
    stage('Build and tag') {
      steps { sh 'docker build -t "$IMAGE" . && docker tag "$IMAGE" devops-mini-lab:latest' }
    }
    stage('Deploy') {
      steps {
        sh '''#!/bin/bash
set -euo pipefail
docker save "$IMAGE" | docker exec -i k3d-devops-mini-lab-server-0 ctr -n k8s.io images import -
'''
        sh 'kubectl apply -f k8s/namespace.yml && kubectl apply -f k8s/ && kubectl -n devops-mini-lab set image deployment/app app="$IMAGE"'
        sh 'kubectl -n devops-mini-lab rollout status deployment/app --timeout=180s'
      }
    }
    stage('Health') { steps { sh 'scripts/smoke.sh' } }
  }
  post {
    always {
      junit allowEmptyResults: true, testResults: 'reports/pytest.xml'
      archiveArtifacts allowEmptyArchive: true, artifacts: 'reports/*.xml'
    }
    failure {
      sh 'kubectl -n devops-mini-lab get pods -o wide || true; kubectl -n devops-mini-lab describe deployment app || true; kubectl -n devops-mini-lab logs deployment/app --all-containers --tail=100 || true'
    }
  }
}
