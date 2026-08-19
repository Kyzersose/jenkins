FROM jenkins/jenkins:lts-jdk21

USER root

# Docker CLI only -- deliberately NOT the docker daemon (docker-ce).
# The CLI is just a client; it talks to the host's daemon over the socket
# that gets bind-mounted in at /var/run/docker.sock. Containers built by
# pipelines are therefore siblings of this container, not children of it.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl gnupg gosu unzip \
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

# Maven and Gradle, baked into the image as fixed local installs (downloaded
# once at build time, checksum-verified) rather than relying on Jenkins'
# built-in tool installers to fetch them at build/run time. Global Tool
# Configuration below (casc.yaml) points straight at these paths.
ARG MAVEN_VERSION=3.9.16
ARG MAVEN_SHA512=831a8591fe20c8243b1dbe7d71e3244f31d1665b0804b2e825e38cbbe5ce0cafb8338851f90780735568773e0a6cd07bbec107cda0b896b008b861075358b6f6
ARG GRADLE_VERSION=9.7.0
ARG GRADLE_SHA256=84fbba45c7f4c64abc77460e1c00f541e9f960e3c7ed2538f1ede19eacd873ae

RUN curl -fsSL -o /tmp/maven.tar.gz \
      "https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" \
 && echo "${MAVEN_SHA512}  /tmp/maven.tar.gz" | sha512sum -c - \
 && tar -xzf /tmp/maven.tar.gz -C /opt \
 && ln -s "/opt/apache-maven-${MAVEN_VERSION}" /opt/maven \
 && rm /tmp/maven.tar.gz \
 && curl -fsSL -o /tmp/gradle.zip \
      "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
 && echo "${GRADLE_SHA256}  /tmp/gradle.zip" | sha256sum -c - \
 && unzip -q /tmp/gradle.zip -d /opt \
 && ln -s "/opt/gradle-${GRADLE_VERSION}" /opt/gradle \
 && rm /tmp/gradle.zip

# AWS CLI. Arch-detected the same way the Docker apt repo is above --
# this image gets built natively on both Apple Silicon (arm64) and x86_64
# hosts, and the x86_64 zip fails under Rosetta with a missing
# /lib64/ld-linux-x86-64.so.2 on an arm64 base image.
RUN AWS_CLI_ARCH="$(dpkg --print-architecture | sed 's/amd64/x86_64/; s/arm64/aarch64/')" \
 && curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_CLI_ARCH}.zip" -o awscliv2.zip \
 && unzip -q awscliv2.zip \
 && ./aws/install \
 && rm -rf awscliv2.zip ./aws

COPY --chmod=0755 entrypoint.sh /usr/local/bin/jenkins-with-docker.sh

# Registers the JDK already shipped by the base image (JAVA_HOME) plus the
# Maven/Gradle installs above as Global Tool Configuration entries, so
# pipelines can reference them by name without Jenkins trying to download
# anything itself. Lives outside /var/jenkins_home because that path is a
# volume mount -- anything copied there in the image is invisible once the
# named volume already has content.
ENV CASC_JENKINS_CONFIG=/usr/share/jenkins/casc.yaml
COPY casc.yaml /usr/share/jenkins/casc.yaml

# Plugins are baked into the image so a rebuild reproduces the same Jenkins.
# jenkins-plugin-cli must run as the jenkins user (it writes to its ref dir).
USER jenkins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Start as root so the entrypoint can fix socket permissions, then it drops
# privileges back to the jenkins user with gosu before Jenkins itself starts.
USER root
ENTRYPOINT ["/usr/local/bin/jenkins-with-docker.sh"]
