//Declarative Pipeline
pipeline {
    agent none
    environment {
        PROJECT = "WELCOME TO DEVOPS-Terrafor-Ansible-GITHUB-DOCKER-JENKINS PROJECT"
    }
    stages {
        stage('Deploy To Development') {
            agent { label 'DEV' }
            environment {
            DEVDEFAULTAMI = "ami-07f5002e4ab04a0b4"
            PACKER_ACTION = "NO" //YES or NO
            TERRAFORM_APPLY = "NO" //YES or NO
            TERRAFORM_DESTROY = "NO" //YES or NO
            ANSIBLE_ACTION = "NO" //YES or NO
            }
            when {
                branch 'development'
            }
            stages {
                stage('Perform Packer Build') {
                    when {
                        expression {
                            "${env.PACKER_ACTION}" == 'YES'
                        }
                    }
                    steps { //Assume Role in Mohammed Rahamadulla AWS Account
                        withAWS(role:'DevOpsJenkinsAssumeRole', roleAccount:'872009735319', duration: 900, roleSessionName: 'jenkins-session') {
                            sh 'pwd'
                            sh 'rm -f prod-backend.tf'
                            sh 'ls -al'
                            sh 'packer build -var-file packer-vars-dev.json packer.json | tee output.txt'
                            sh "tail -2 output.txt | head -2 | awk 'match(\$0, /ami-.*/) { print substr(\$0, RSTART, RLENGTH) }' > ami.txt"
                            sh "echo \$(cat ami.txt) > ami.txt"
                            script {
                                def AMIID = readFile('ami.txt').trim()
                                sh 'echo "" >> variables.tf'
                                sh "echo variable \\\"imagename\\\" { default = \\\"$AMIID\\\" } >> variables.tf"
                            }
                        }
                    }
                }
                stage('No Packer Build') {
                    when {
                        expression {
                            "${env.PACKER_ACTION}" == 'NO'
                        }
                    }
                    steps {
                        sh 'pwd'
                        sh 'ls -al'
                        sh 'echo "" >> variables.tf'
                        sh "echo variable \\\"imagename\\\" { default = \\\"${env.DEVDEFAULTAMI}\\\" } >> variables.tf"
                    }
                }
                stage('Terraform Plan') {
                    when {
                        expression {
                            "${env.TERRAFORM_APPLY}" == 'YES'
                        }
                    }
                    steps {
                        withAWS(role:'DevOpsJenkinsAssumeRole', roleAccount:'872009735319', duration: 900, roleSessionName: 'jenkins-session') {
                            sh 'rm -rf .terraform'
                            sh 'rm -f prod-backend.tf'
                            sh 'terraform init'
                            sh 'terraform validate'
                            sh 'terraform plan'
                        }
                    }
                }
                stage('Terraform Apply') {
                    when {
                        expression {
                            "${env.TERRAFORM_APPLY}" == 'YES'
                        }
                    }
                    steps {
                        withAWS(role:'DevOpsJenkinsAssumeRole', roleAccount:'872009735319', duration: 900, roleSessionName: 'jenkins-session') {
                            sh 'rm -rf .terraform'
                            sh 'terraform init'
                            sh 'terraform apply --auto-approve'
                        }
                    }
                }
                stage('Validate Ansible Playbook & Dry Run') {
                    when {
                        expression {
                            "${env.ANSIBLE_ACTION}" == 'YES'
                        }
                    }
                    steps {
                        sh 'sleep 15'
                        sh 'ansible-playbook -i invfile docker-swarm.yml --syntax-check'
                        //Used withCredentials for dry-run as ansible plugin dont have --check option.
                        //withCredentials([file(credentialsId: 'LaptopKey', variable: 'ansiblepvtkey')]) {
                        //sh "sudo cp \$ansiblepvtkey $WORKSPACE"
                        //sh "ls -al"
                        sh "sudo ansible-playbook -i invfile docker-swarm.yml -u ansibleadmin --private-key=/var/lib/jenkins/ansibleadminkey --check"
                        }
                          
                    }
                }
                stage('Run Ansible Playbook') {
                    when {
                        expression {
                            "${env.ANSIBLE_ACTION}" == 'YES'
                        }
                    }
                    steps {
                        sh 'ansible-playbook -i invfile docker-swarm.yml -u ansibleadmin --private-key=/var/lib/jenkins/ansibleadminkey -vv'
                        //ansiblePlaybook credentialsId: 'ansibleadmin', disableHostKeyChecking: true, installation: 'Ansible', inventory: 'invfile', playbook: 'docker-swarm.yml'  
                    }
                }
                stage('Terraform Destroy') {
                    when {
                        expression {
                            "${env.TERRAFORM_DESTROY}" == 'YES'
                        }
                    }
                    steps {
                        withAWS(role:'DevOpsJenkinsAssumeRole', roleAccount:'872009735319', duration: 900, roleSessionName: 'jenkins-session') {
                            sh 'rm -f prod-backend.tf'
                            sh 'terraform init'
                            sh 'terraform destroy --auto-approve'
                        }
                    }
                }
            }
        }
        stage('Deploy To Production') {
            agent { label 'PROD' }
            environment {
            PRODEFAULTAMI = "ami-08d19d3f9e33fad33"
            PACKER_ACTION = "NO" //YES or NO
            TERRAFORM_APPLY = "NO" //YES or NO
            TERRAFORM_DESTROY = "NO" //YES or NO
            ANSIBLE_ACTION = "NO" //YES or NO
            }
            when {
                branch 'production'
            }
            stages {
                stage('Perform Packer Build') {
                    when {
                        expression {
                            "${env.PACKER_ACTION}" == 'YES'
                        }
                    }
                    steps { //Assume Role in Mohammed Rahamadulla AWS Account
                        withAWS(role:'DevOpsJenkinsAssumeRole', roleAccount:'872009735319', duration: 900, roleSessionName: 'jenkins-session') {
                            sh 'pwd'
                            sh 'ls -al'
                            sh 'packer build -var-file packer-vars-prod.json packer.json | tee output.txt'
                            sh "tail -2 output.txt | head -2 | awk 'match(\$0, /ami-.*/) { print substr(\$0, RSTART, RLENGTH) }' > ami.txt"
                            sh "echo \$(cat ami.txt) > ami.txt"
                            script {
                                def AMIID = readFile('ami.txt').trim()
                                sh 'echo "" >> variables.tf'
                                sh "echo variable \\\"imagename\\\" { default = \\\"$AMIID\\\" } >> variables.tf"
                            }
                        }
                    }
                }
                stage('No Packer Build') {
                    when {
                        expression {
                            "${env.PACKER_ACTION}" == 'NO'
                        }
                    }
                    steps {
                        sh 'pwd'
                        sh 'ls -al'
                        sh 'echo "" >> variables.tf'
                        sh "echo variable \\\"imagename\\\" { default = \\\"${env.PRODEFAULTAMI}\\\" } >> variables.tf"
                    }
                }
                stage('Terraform Plan') {
                    when {
                        expression {
                            "${env.TERRAFORM_APPLY}" == 'YES'
                        }
                    }
                    steps {
                        withAWS(role:'DevOpsJenkinsAssumeRole', roleAccount:'872009735319', duration: 900, roleSessionName: 'jenkins-session') {
                            sh 'rm -rf .terraform'
                            sh 'rm -f dev-backend.tf'
                            sh 'terraform init'
                            sh 'terraform validate'
                            sh 'terraform plan'
                        }
                    }
                }
                stage('Terraform Apply') {
                    when {
                        expression {
                            "${env.TERRAFORM_APPLY}" == 'YES'
                        }
                    }
                    steps {
                        withAWS(role:'DevOpsJenkinsAssumeRole', roleAccount:'872009735319', duration: 900, roleSessionName: 'jenkins-session') {
                            sh 'rm -rf .terraform'
                            sh 'terraform init'
                            sh 'terraform apply --auto-approve'
                        }
                    }
                }
                stage('Validate Ansible Playbook & Dry Run') {
                    when {
                        expression {
                            "${env.ANSIBLE_ACTION}" == 'YES'
                        }
                    }
                    steps {
                        sh 'sleep 15'
                        sh 'ansible-playbook -i invfile docker-swarm.yml --syntax-check'
                        //sh 'ansible-playbook -i invfile docker-swarm.yml --check --user ansibleadmin'
                        sh 'ansible-playbook -i invfile docker-swarm.yml -u ansibleadmin --private-key=/var/lib/jenkins/logs/ansibleadminkey --check'
                    }
                }
                stage('Run Ansible Playbook') {
                    when {
                        expression {
                            "${env.ANSIBLE_ACTION}" == 'YES'
                        }
                    }
                    steps {
                        sh 'ansible-playbook -i invfile docker-swarm.yml --user ansibleadmin -vv'
                        //ansiblePlaybook credentialsId: 'ansibleadmin', disableHostKeyChecking: true, installation: 'Ansible', inventory: 'invfile', playbook: 'docker-swarm.yml'  
                    }
                }
                stage('Terraform Destroy') {
                    when {
                        expression {
                            "${env.TERRAFORM_DESTROY}" == 'YES'
                        }
                    }
                    steps {
                        withAWS(role:'DevOpsJenkinsAssumeRole', roleAccount:'872009735319', duration: 900, roleSessionName: 'jenkins-session') {
                            sh 'rm -f dev-backend.tf'
                            sh 'terraform init'
                            sh 'terraform destroy --auto-approve'
                        }
                    }
                }
            }
        }

    }
