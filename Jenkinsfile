pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  environment {
    AWS_DEFAULT_REGION = "us-east-1"
    TF_IN_AUTOMATION   = "true"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Init') {
      steps {
        dir('envs/prod') {
          sh 'terraform --version'
          sh 'terraform init'
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        dir('envs/prod') {
          sh 'terraform plan -out=tfplan'
        }
      }
    }

    stage('Terraform Apply (Manual Approval)') {
      steps {
        input message: "Approve APPLY to PROD?", ok: "Apply"
        dir('envs/prod') {
          sh 'terraform apply -auto-approve tfplan'
        }
      }
    }
  }

  post {
    always {
      dir('envs/prod') {
        sh 'terraform show -no-color || true'
      }
    }
  }
}
