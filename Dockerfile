FROM jenkins/jenkins:lts-jdk21

USER root

# Docker CLI only -- deliberately NOT the docker daemon (docker-ce).
# The CLI is just a client; it talks to the host's daemon over the socket
# that gets bind-mounted in at /var/run/docker.sock. Containers built by
# pipelines are therefore siblings of this container, not children of it.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl gnupg gosu \
 && install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/debian/gpg \
      -o /etc/apt/keyrings/docker.asc \
 && chmod a+r /etc/apt/keyrings/docker.asc \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
      > /etc/apt/sources.list.d/docker.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      docker-ce-cli docker-buildx-plugin docker-compose-plugin \
 && rm -rf /var/lib/apt/lists/*

COPY --chmod=0755 entrypoint.sh /usr/local/bin/jenkins-with-docker.sh

# Plugins are baked into the image so a rebuild reproduces the same Jenkins.
# jenkins-plugin-cli must run as the jenkins user (it writes to its ref dir).
USER jenkins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Start as root so the entrypoint can fix socket permissions, then it drops
# privileges back to the jenkins user with gosu before Jenkins itself starts.
USER root
ENTRYPOINT ["/usr/local/bin/jenkins-with-docker.sh"]
