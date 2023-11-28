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

        stage('plan') {
            steps {
                sh 'terraform plan --var-file=dev-vars.tfvars -out=devplan'
            }
        }


        stage('apply') {
            steps {
                sh 'terraform apply -auto-approve devplan'
            }
        }

    }
}
