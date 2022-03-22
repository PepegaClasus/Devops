pipeline{
    agent any
    environment {
        dockerImage = ''
    }
    stages {
        stage ('Checkout'){
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/staging']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-ssh-keygen', url: 'git@github.com:PepegaClasus/Devops.git']]])
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
                    def dockerRun = 'docker run -p 8080:8080 -d --name {container_name} "${USR}/${DOCKER_IMAGE_NAME}"'
                    sshagent(['dev-server']) {
                        sh "ssh -o StrictHostKeyChecking=no ubuntu@44.201.33.118 ${dockerRun}"
                    }
                }
            }
        }
    }
}
