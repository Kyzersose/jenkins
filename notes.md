# Server UPDATE!
1. Digital Ocean
2. Regular > 4GB > $24/month
3. Name: jenkins-server
4. Configure firewall for:
    - 22
    - 8080
# UPDATE!
Switched to AWS. A lot cheaper if you only use them when you're learning.
- Login:
    - ssh -i ~/.ssh/cct-ssh.pem ubuntu@jenkins.cristocreativetech.com


# Fresh install
1. apt update && apt upgrade
2. apt install docker

# Docker
1. docker run -p 8080:8080 -p 50000:50000 -d -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts
2. Created a new contiainer with added volume so Jenkins can use it. Attached persisted data too!
    - docker run -p 8080:8080 -p 50000:50000 -d -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins/jenkins:lts
3. need to continue to allow docker socket for container:
    - docker exec -it -u 0 (jenkins-continer) bash
    - chmod 666 /var/run/docker.sock

# Jenkins setup
1. docker exec -it {container} /bin/bash
2. cat /var/jenkins_home/secrets/initialAdminPassword

# Tools
1. Setup Maven
2. installed node and npm via ssh as an example

# Plugins
1. Stage view
2. Nodejs

# Fun fact
- You could install tools (npm, maven) directly on the Jenkins server rather than installing a plugin. This isn't ideal though.

# Issues
1.  To login securely via docker hub to pipeline your pwd ex:
    - echo "YOUR_ACCESS_TOKEN" | docker login -u "YOUR_USERNAME" --password-stdin