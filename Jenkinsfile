pipeline {
    agent any
    tools {
        maven 'maven-3.9'
    }
    stages {
        stage('build jar') {
            steps {
                echo 'Building the application'
                sh 'mvn package'
            }
        }
        stage('build image') {
            steps {
                echo 'Building the Docker image'
                withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'DOCKER_HUB_PASSWORD', usernameVariable: 'DOCKER_HUB_USERNAME')]) {
                    sh 'docker build -t kyzersose/nana-jenkins-demo:jma2.1 .'
                    sh 'echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USERNAME --password-stdin'
                    sh 'docker push kyzersose/nana-jenkins-demo:jma2.1  '
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    echo 'Deploying the application'
                }
            }
        }
    }
}