pipeline {
  agent any

  environment {
    AWS_DEFAULT_REGION = 'us-east-1'
    ENV_DIR            = 'envs/prod'
  }

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  stages {
    stage('Checkout') {
      steps {
        // Clean workspace to avoid "No changes" confusion / cached files
        deleteDir()
        checkout scm
      }
    }

    stage('Install Terraform (if missing)') {
      steps {
        sh '''
          set -e
          if ! command -v terraform >/dev/null 2>&1; then
            echo "Terraform not found. Installing..."
            sudo yum install -y unzip curl >/dev/null 2>&1 || true
            TF_VERSION="1.7.5"
            curl -fsSL -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
            unzip -o /tmp/terraform.zip -d /tmp
            sudo mv /tmp/terraform /usr/local/bin/terraform
            sudo chmod +x /usr/local/bin/terraform
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

    stage('Terraform Format & Validate') {
      steps {
        sh '''
          set -e
          cd ${ENV_DIR}
          terraform fmt -check -recursive
          terraform validate
        '''
      }
    }

    stage('Terraform Plan') {
      steps {
        sh '''
          set -e
          cd ${ENV_DIR}
          terraform plan -input=false
        '''
      }
    }

    stage('Approval') {
      steps {
        input message: "Apply Terraform changes to PROD?", ok: "Yes, Apply"
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
    always {
      echo "Pipeline finished (success or failure)."
    }
  }
}
