pipeline {
  agent { label 'terraform' }

  environment {
    AWS_DEFAULT_REGION = 'us-east-1'
    ENV_DIR            = 'envs/prod'
    TF_IN_AUTOMATION   = 'true'
    TF_INPUT           = 'false'
    TF_PLUGIN_CACHE_DIR = "${WORKSPACE}/.terraform.d/plugin-cache"
  }

  options {
    timestamps()
    disableConcurrentBuilds()
    timeout(time: 45, unit: 'MINUTES')
  }

  stages {
    stage('Checkout') {
      steps {
        cleanWs()
        checkout scm
      }
    }

    stage('Tools Check') {
      steps {
        sh '''
          set -eux
          df -h
          java -version
          git --version
          terraform version || true
        '''
      }
    }

    stage('Install Terraform (if missing)') {
      steps {
        sh '''
          set -e
          if ! command -v terraform >/dev/null 2>&1; then
            echo "Terraform not found. Installing..."
            sudo dnf -y install unzip || true
            sudo dnf -y swap curl-minimal curl --allowerasing || sudo dnf -y install curl --allowerasing

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
          set -eux
          mkdir -p "${TF_PLUGIN_CACHE_DIR}"
          cd "${ENV_DIR}"
          terraform init -upgrade
        '''
      }
    }

    stage('Terraform Format & Validate') 
      steps {
        sh '''
          set -eux
          cd "${ENV_DIR}"
          terraform fmt -check -recursive
          terraform validate
        '''
      }
    }

    stage('Terraform Plan') {
      steps {
        sh '''
          set -eux
          cd "${ENV_DIR}"
          terraform plan -out=tfplan
        '''
        archiveArtifacts artifacts: "${ENV_DIR}/tfplan", fingerprint: true
      }
    }

    stage('Approval') {
      steps {
        timeout(time: 15, unit: 'MINUTES') {
          input message: "Apply Terraform changes to PROD?", ok: "Yes, Apply"
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        sh '''
          set -eux
          cd "${ENV_DIR}"
          terraform apply -auto-approve tfplan
        '''
      }
    }
  }

  post {
    always {
      sh '''
        set +e
        echo "Disk after run:"
        df -h
      '''
      cleanWs()
      echo "Pipeline finished."
    }
  }
}
