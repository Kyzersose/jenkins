# nana-jenkins

This stands up a Jenkins server to be used as part of the Nana DevOps course.
Because I don't want to pay the cloud costs! Especially since it's taking 
much longer to finish the class than I had planned.

## Architecture

jenkins.theshaeffers.com (cloudflare tunnel) -> raspberry pi > macbook air jenkins container

- `Dockerfile` —
- `docker-compose.yml` —
- `entrypoint.sh` —
- `plugins.txt` —
- `Jenkinsfile` —
- `script.groovy` —

## Prerequisites

## Setup

### 1. Build and start Jenkins
docker compose build && docker compose up -d

### 2. Initial admin password
docker exec -it jenkins "cat /var/lib/jenkins/secrets/initialAdminPassword"

### 3. Jenkins URL / instance configuration
https://jenkins.theshaeffers.com

### 4. Tools

plugins.txt adds the plugins for Jenkins
