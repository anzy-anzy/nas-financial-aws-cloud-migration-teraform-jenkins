pipeline {
  agent any

  environment {
    ENV_DIR   = "envs/prod"
    TF_IN_AUTOMATION = "true"
    TF_INPUT  = "false"
  }

  options {
    timestamps()
    ansiColor('xterm')
    disableConcurrentBuilds()
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Install Terraform (if missing)') {
      steps {
        sh '''
          set -e
          if ! command -v terraform >/dev/null 2>&1; then
            echo "Terraform not found. Installing..."
            sudo yum install -y yum-utils
            sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
            sudo yum -y install terraform
          fi
          terraform version
        '''
      }
    }

    stage('Terraform Init') {
      steps {
        sh '''
          set -e
          cd ${ENV_DIR}
          terraform init -input=false
        '''
      }
    }

    stage('Terraform Format Check') {
      steps {
        sh '''
          set -e
          cd ${ENV_DIR}
          terraform fmt -check -recursive
        '''
      }
    }

    stage('Terraform Validate') {
      steps {
        sh '''
          set -e
          cd ${ENV_DIR}
          terraform validate
        '''
      }
    }

    stage('Terraform Plan') {
      steps {
        sh '''
          set -e
          cd ${ENV_DIR}
          terraform plan -input=false -no-color | tee tfplan.txt
        '''
      }
      post {
        always {
          archiveArtifacts artifacts: "${ENV_DIR}/tfplan.txt", fingerprint: true, onlyIfSuccessful: false
        }
      }
    }

    stage('Approval') {
      steps {
        input message: "Approve Terraform APPLY for ${ENV_DIR}?"
      }
    }

    stage('Terraform Apply') {
      steps {
        sh '''
          set -e
          cd ${ENV_DIR}
          terraform apply -auto-approve -input=false
        '''
      }
    }
  }

  post {
    success {
      echo "✅ Pipeline completed successfully."
    }
    failure {
      echo "❌ Pipeline failed. Open the stage logs to see the exact error."
    }
  }
}
