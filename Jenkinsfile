

pipeline {
    agent any

    stages {
        stage('Create Infrastructure') {
            steps {
                script {
                    echo 'Creating Infrastructure for the App on AWS Cloud'
                    sh 'terraform init'
                    sh 'terraform apply --auto-approve'
                }
            }
        }

        stage('Add NAT Instance to Private Route Table') {
            steps {
                script {
                    def natInstanceId = sh(script: 'aws ec2 describe-instances --filters "Name=tag:Name,Values=Proje2 Nat Instance" --query "Reservations[*].Instances[*].[InstanceId]" --output text', returnStdout: true).trim()
                    def privateRouteTableId = sh(script: 'aws ec2 describe-route-tables --filters "Name=tag:Name,Values=proje2-private-RT" --query "RouteTables[*].[RouteTableId]" --output text', returnStdout: true).trim()

                    sh "aws ec2 associate-route-table --route-table-id ${privateRouteTableId} --instance-id ${natInstanceId}"
                }
            }
        }

        stage('Destroy the infrastructure'){
            steps{
                timeout(time:5, unit:'DAYS'){
                    input message:'Approve terminate'
                }
                sh """
                terraform destroy --auto-approve
                """
            }
        }
    }

    post {
        always {
            echo 'Deleting all local images'
            sh 'docker image prune -af'
        }
        failure {
            echo 'Deleting Terraform Stack due to the Failure'
                sh 'terraform destroy --auto-approve'
        }

    }
}











