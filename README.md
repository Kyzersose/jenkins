# Homelab-jenkins

This stands up a Jenkins server to be used as part of the Nana DevOps course.
Because I don't want to pay the cloud costs! Especially since it's taking 
much longer to finish the class than I had planned.

## Architecture

jenkins.theshaeffers.com (cloudflare tunnel) -> raspberry pi > macbook air jenkins container

- `Dockerfile` — builds the image, calls or copies the other files
- `docker-compose.yml` — builds the docker network and container
- `entrypoint.sh` — runs on every container start, fixes bind permissions for /var/run/docker.sock
- `plugins.txt` — Plugins installed for Jenkins
- `casc.yaml` — Global Tool Configuration (JDK/Maven/Gradle local installs)

## Setup

### 1. Build and start Jenkins
docker compose build && docker compose up -d

### 2. Initial admin password
docker exec -it jenkins "cat /var/lib/jenkins/secrets/initialAdminPassword"

### 3. Jenkins URL / instance configuration
https://jenkins.theshaeffers.com

### 4. Tools

plugins.txt adds the plugins for Jenkins.

JDK, Maven, and Gradle are baked into the image as fixed local installs
(downloaded and checksum-verified in the Dockerfile, not fetched by
Jenkins' own tool installers) and registered in Global Tool Configuration
via `casc.yaml`:

| Tool   | Name (used in `tools {}`) | Path            |
|--------|----------------------------|-----------------|
| JDK    | `jdk21`                    | `/opt/java/openjdk` (ships with the base image) |
| Maven  | `maven-3.9`                 | `/opt/maven`    |
| Gradle | `gradle-9`                  | `/opt/gradle`   |

Bump versions via the `MAVEN_VERSION`/`GRADLE_VERSION` build args in the
Dockerfile (update the matching `*_SHA512`/`*_SHA256` args alongside).
