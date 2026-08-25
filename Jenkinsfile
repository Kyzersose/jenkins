pipeline {
    agent any
    tools {
        nodejs "node"
    }
    stages {
        stage('increment version') {
            steps {
                script {
                    // enter app directory, because that's where package.json is located
                    dir("app") {
                        // update application version in the package.json file with one of these release types: patch, minor or major
                        // This command updates the minor version in package.json and ensures no Git commands are executed in the background, preventing automatic commits or tags in your Jenkins Pipeline
                        sh "npm version minor —no-git-tag-version"

                        // read the updated version from the package.json file
                        def packageJson = readJSON file: 'package.json'
                        def version = packageJson.version

                        // set the new version as part of IMAGE_NAME
                        env.IMAGE_NAME = "$version-$BUILD_NUMBER"
                    }

                }
            }
        }
        stage('Run tests') {
            steps {
               script {
                    dir("app") {
                        // install all dependencies needed for running tests
                        sh "npm install"
                        sh "npm run test"
                    }
               }
            }
        }
        stage('Build and Push docker image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-kyzersose', usernameVariable: 'USER', passwordVariable: 'PASS')]){
                    sh "docker build -t docker-hub-id/myapp:${IMAGE_NAME} ."
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                    sh "docker push docker-hub-id/myapp:${IMAGE_NAME}"
                }
            }
        }
        stage('commit version update') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'gitlab-personal', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        // git config here for the first time run
                        sh 'git config --global user.email "jenkins@example.com"'
                        sh 'git config --global user.name "jenkins"'
                        sh 'git remote set-url origin https://$USER:$PASS@gitlab.com/twn-devops-bootcamp/latest/08-jenkins/jenkins-exercises.git'
                        sh 'git add .'
                        sh 'git commit -m "ci: version bump"'
                        sh 'git push origin HEAD:jenkins-jobs'
                    }
                }
            }
        }
    }
}
