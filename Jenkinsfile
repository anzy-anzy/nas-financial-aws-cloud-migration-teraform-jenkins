pipeline {
  agent any

  environment {
    AWS_REGION = "us-east-1"
    TF_IN_AUTOMATION = "true"
    TF_INPUT = "false"
    ENV_DIR = "envs/prod"
  }

  options {
    timestamps()
  }

  stages {
    stage("Checkout") {
      steps {
        checkout scm
      }
    }

    stage("Install Terraform (if missing)") {
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

    stage("Terraform Format & Validate") {
      steps {
        sh '''
          set -e
          cd ${ENV_DIR}
          terraform fmt -check -recursive
          terraform validate
        '''
      }
    }

    stage("Terraform Init") {
      steps {
        sh '''
          set -e
          cd ${ENV_DIR}
          terraform init -input=false
        '''
      }
    }

    stage("Terraform Plan") {
      steps {
        sh '''
          set -e
          cd ${ENV_DIR}
          terraform plan -out=tfplan
        '''
      }
    }

    stage("Approval") {
      steps {
        input message: "Approve Terraform APPLY to PROD?", ok: "Apply"
      }
    }

    stage("Terraform Apply") {
      steps {
        sh '''
          set -e
          cd ${ENV_DIR}
          terraform apply -auto-approve tfplan
        '''
      }
    }
  }

  post {
    always {
      echo "Pipeline finished."
    }
  }
}
