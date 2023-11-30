pipeline {
    
   agent any

    parameters {
        string(name: 'environment', defaultValue: '', description: 'Ambiente a desplegar')
    }
    
    /*
    environment {
      TEST_TIME_OUT='30m'
    }

    options {
        timeout(time: 30, unit: 'MINUTES')
        ansiColor('xterm')
    }*/

    stages {

         stage('init') {
            steps {
                sh 'terraform init -migrate-state -force-copy'
            }
        }

        stage('Init workspace') {
            steps {
                sh 'terraform init'
                sh '''
                    if [ $(terraform workspace list | grep "${params.environment}" | wc -l) -lt 1 ]; then
                        terraform workspace new "${params.environment}"
                        else
                            echo "Workspace ${params.environment} existente."
                        fi
                    '''
                sh "terraform workspace select ${params.environment}"
                sh "terraform plan -refresh-only -var-file=\"${params.environment}-vars.tfvars\""
            }
        }

        stage('Validate') {
            steps {
                sh 'terraform validate'
            }
        }


        stage('plan') {
            steps {
                sh 'terraform plan -var-file=\"${params.environment}-vars.tfvars\" -out=testplan.plan'
            }
        }

        stage('confirmacion') {
                 input {
	                message "Apruebas el despliegue en el ambiente: ${params.environment}"
	                ok 'Desplegar'
	                submitterParameter 'approvedBy'
	            }
	            steps {
	                echo "Despliegue aprobado por: ${approvedBy}."
	            }   
        }

        stage('apply') {
            steps {
                sh 'terraform apply -auto-approve testplan.plan'
            }
        }
    }

}