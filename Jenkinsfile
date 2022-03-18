pipeline{
    agent any
    environment {
        dockerImage = ''
    }
    stages {
        stage ('Checkout'){
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/test_staging']], extensions: [], userRemoteConfigs: [[credentialsId: 'pepegaclaus_main', url: 'git@github.com:PepegaClasus/Devops.git']]])
            }
        }
        stage ('Build docker image'){
            steps{
                script{
                   withCredentials([usernamePassword(credentialsId:"${docker_hub_credential}", usernameVariable: 'USR', passwordVariable: "PASSWORD")]){
                       dockerImage = docker.build "${USR}/${DOCKER_IMAGE_NAME}"
                   }
                }
            }
        }
        
        stage ('Backup'){
            steps {
                script {
                    docker.withRegistry('', "${docker_hub_credential}") {
                        dockerImage.push()
                    }
                }
            }
        }
        stage ('Push to Remote server'){
            steps{
                script{
                    def dockerRun = 'docker run -d -p 80:8080 --name nodehelloapp "${USR}/${DOCKER_IMAGE_NAME}"'
                    sshagent(['dev-server']) {
                        sh "ssh -o StrictHostKeyChecking=no ubuntu@44.199.250.204 ${dockerRun}"
                    }
                }
            }
        }
    }
}
