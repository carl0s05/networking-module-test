pipeline {
    agent any

    stages {

        stage('init') {
            steps {
                sh 'terraform init -migrate-state -force-copy'
            }
        }

        stage('validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('workspace') {
            steps {
                sh 'terraform workspace list'
            }
        }

         stage('workspace-list') {
            steps {
                sh 'terraform workspace new dev'
            }
        }

         stage('workspace-selesct') {
            steps {
                sh 'terraform workspace select dev'
            }
        }

        stage('plan') {
            steps {
                sh 'terraform plan --var-file=dev-vars.tfvars -out=devplan'
            }
        }

        stage('aprobacion') {
                 steps {
                    input('Confirmas realizar el despliegue?')
                 }
        }

        stage('apply') {
            steps {
                sh 'terraform apply devplan'
            }
        }
/*
        stage('destroy') {
            steps {
                sh 'terraform destroy -auto-approve --var-file=dev-vars.tfvars'
            }
        }
*/
    }
}
