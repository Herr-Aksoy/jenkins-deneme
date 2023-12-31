

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

        // stage('Auto Scaling Grubundan Özel IP\'leri Al') {
        //     steps {
        //         script {
                    
        //             def instanceIds = sh(
        //                 script: 'aws autoscaling describe-auto-scaling-instances --query "AutoScalingInstances[?AutoScalingGroupName==proje2_ASG].InstanceId" --output text',
        //                 returnStdout: true
        //             ).trim().split()

        //             def privateIps = []
        //             instanceIds.each { instanceId ->
        //                  def privateIp = sh(
        //                      script: "aws ec2 describe-instances --instance-ids ${instanceId} --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text",
        //                      returnStdout: true
        //                  ).trim()
        //                  privateIps.add(privateIp)
        //             }

        //             sh "touch ip_addresses.txt"

        //             echo "Private IPs:\n${privateIps}" 
        //             writeFile file: 'ip_addresses.txt', text: privateIps.join('\n')
        //         }
        //     }
        // }
    

        stage('SSH ile Ansible EC2 Örneğine Bağlan') {
            steps {
                script {
                    def awsCliCommand = """
                        aws ec2 describe-instances 
                        --filters "Name=tag:Name,Values=Ansible-instance" "Name=instance-state-name,Values=running" 
                        --query "Reservations[*].Instances[*].PrivateIpAddress" 
                        --output text
                    """
                    
                    sh "scp -i ./ramo.pem -o StrictHostKeyChecking=no ip_addresses.txt ec2-user@${privateIp}:/home/ec2-user/"


                }
            }
        }
    


        stage('Inventory Dosyasını Güncelle') {
            steps {
                script {
                    def ipAddresses = readFile 'ip_addresses.txt'
                    echo "Updated IPs:\n${ipAddresses}" 
            
                    sh """
                    sed -i ./ramo.pem ec2-user@${privateIp} 's/IP1/${ipAddresses.split()[0]}/g' /home/ec2-user/inventory
                    sed -i ./ramo.pem ec2-user@${privateIp} 's/IP2/${ipAddresses.split()[1]}/g' /home/ec2-user/inventory
                    """
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











