pipeline {
  agent { label 'terraform' }

  environment {
    AWS_DEFAULT_REGION = 'us-east-1'
    ENV_DIR            = 'envs/prod'
    TF_IN_AUTOMATION   = 'true'
    TF_INPUT           = 'false'

    // Cache providers so we don't re-download every build
    TF_PLUGIN_CACHE_DIR = '/home/ec2-user/.terraform.d/plugin-cache'
  }

  options {
    timestamps()
    disableConcurrentBuilds()
    timeout(time: 45, unit: 'MINUTES')
  }

  stages {
    stage('Checkout') {
      steps {
        deleteDir()
        checkout scm
        stash name: 'src', includes: '**/*'
      }
    }

    stage('Prepare Agent') {
      steps {
        unstash 'src'
        sh '''
          set -e

          # Create plugin cache directory
          mkdir -p "$TF_PLUGIN_CACHE_DIR"

          # Ensure required tools exist
          if ! command -v unzip >/dev/null 2>&1; then
            sudo dnf -y install unzip
          fi

          # Ensure curl exists (AL2023 sometimes has curl-minimal conflicts)
          if ! command -v curl >/dev/null 2>&1; then
            sudo dnf -y swap curl-minimal curl --allowerasing || sudo dnf -y install curl --allowerasing
          fi

          # Install Terraform if missing
          if ! command -v terraform >/dev/null 2>&1; then
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
          set -e
          cd "${ENV_DIR}"
          terraform init -input=false -upgrade
        '''
      }
    }

    stage('Terraform Format & Validate') {
      steps {
        sh '''
          set -e
          cd "${ENV_DIR}"
          terraform fmt -check -recursive
          terraform validate
        '''
      }
    }

    stage('Terraform Plan') {
      steps {
        sh '''
          set -e
          cd "${ENV_DIR}"
          terraform plan -lock-timeout=5m -out=tfplan
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
          cd "${ENV_DIR}"
          terraform apply -lock-timeout=5m -input=false tfplan
        '''
      }
    }
  }

  post {
    always {
      echo "Pipeline finished."
      cleanWs(deleteDirs: true, disableDeferredWipeout: true)
    }
  }
}
