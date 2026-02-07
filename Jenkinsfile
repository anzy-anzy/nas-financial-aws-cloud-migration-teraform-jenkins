pipeline {
  agent { label 'terraform' }

  environment {
    AWS_DEFAULT_REGION = 'us-east-1'
    ENV_DIR            = 'envs/prod'
    TF_IN_AUTOMATION   = 'true'
    TF_INPUT           = 'false'
  }

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  stages {
    stage('Checkout') {
      steps {
        deleteDir()
        checkout scm
      }
    }

    stage('Install Terraform (if missing)') {
      steps {
        sh '''
          set -e
          if ! command -v terraform >/dev/null 2>&1; then
            sudo yum install -y unzip curl
            TF_VERSION="1.14.4"
            curl -fsSL -o /tmp/terraform.zip \
              https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
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
          cd ${ENV_DIR}
          terraform init
        '''
      }
    }

    stage('Terraform Format & Validate') {
      steps {
        sh '''
          cd ${ENV_DIR}
          terraform fmt -check -recursive
          terraform validate
        '''
      }
    }

    stage('Terraform Plan') {
      steps {
        sh '''
          cd ${ENV_DIR}
          terraform plan -out=tfplan
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
          cd ${ENV_DIR}
          terraform apply tfplan
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
