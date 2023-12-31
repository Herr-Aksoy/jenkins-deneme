

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

        stage('Auto Scaling Grubundan Özel IP\'leri Al') {
            steps {
                script {
                    sh "touch /home/jenkins/ip_addresses.txt"
                    def instanceIds = sh(
                        script: 'aws autoscaling describe-auto-scaling-instances --query "AutoScalingInstances[?AutoScalingGroupName==proje2_ASG].InstanceId" --output text',
                        returnStdout: true
                    ).trim().split()

                    def privateIps = ""
                    instanceIds.each { instanceId ->
                        def privateIp = sh(
                            script: "aws ec2 describe-instances --instance-ids ${instanceId} --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text",
                            returnStdout: true
                        ).trim()
                        privateIps += "${privateIp}\n"
                    }

                    echo "Private IPs:\n${privateIps}" // IP adreslerini kontrol etmek için yazdırma
                    writeFile file: '/home/jenkins/ip_addresses.txt', text: privateIps
                }
            }
        }

        stage('SSH ile Ansible EC2 Örneğine Bağlan') {
            steps {
                script {
                    def ansibleInstanceId = sh(
                        script: 'aws ec2 describe-instances --filters "Name=tag:Name,Values=Ansible-instance" --query "Reservations[*].Instances[*].InstanceId" --output text',
                        returnStdout: true
                    ).trim()

                    def ansiblePrivateIp = sh(
                        script: "aws ec2 describe-instances --instance-ids ${ansibleInstanceId} --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text",
                        returnStdout: true
                    ).trim()

                    sshagent(credentials: ['ramo.pem']) {
                    // Ansible sunucusuna SSH ile bağlanma ve ramo.pem anahtarını kullanma
                    sh "ssh -i  -o StrictHostKeyChecking=no ec2-user@${ansiblePrivateIp}"
                    }

                    // Jenkins sunucusundaki ip_addresses.txt dosyasını Ansible sunucusuna kopyalama
                    sh "scp -i ./ramo.pem -o StrictHostKeyChecking=no /home/jenkins/ip_addresses.txt ec2-user@${ansiblePrivateIp}:/home/ec2-user/"


                }
            }
        }
    


        stage('Inventory Dosyasını Güncelle') {
            steps {
                script {
                    def ipAddresses = readFile '/home/ec2-user/ip_addresses.txt'
                    echo "Updated IPs:\n${ipAddresses}" // Güncellenmiş IP adreslerini kontrol etmek için yazdırma
            
                    sh """
                    sed -i 's/IP1/${ipAddresses.split()[0]}/g' /home/ec2-user/inventory
                    sed -i 's/IP2/${ipAddresses.split()[1]}/g' /home/ec2-user/inventory
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











