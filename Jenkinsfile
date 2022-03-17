pipeline{
    agent any
    environment {
        dockerImage = ''
        dockerRun = ''
        
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
                    dockerRun = docker run -p 8080:8080 -d -name nodehelloapp "${dockerImage}"
                }
            }
        }
    }
}
