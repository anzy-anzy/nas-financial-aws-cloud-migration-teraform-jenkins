pipeline {
  agent { label 'terraform' }

  environment {
    AWS_DEFAULT_REGION   = 'us-east-1'
    ENV_DIR              = 'envs/prod'
    TF_IN_AUTOMATION     = 'true'
    TF_INPUT             = 'false'

    // Avoid /tmp (often small tmpfs). Put temp downloads/unzips on disk.
    TMPDIR               = '/opt/jenkins/tmp'

    // Speed up provider downloads
    TF_PLUGIN_CACHE_DIR  = "${WORKSPACE}/.terraform.d/plugin-cache"
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
          set -euxo pipefail
          echo "Disk:"
          df -h
          echo "Temp:"
          df -h /tmp || true
          java -version
          git --version
          terraform version || true
        '''
      }
    }

    stage('Install Terraform (if missing)') {
      steps {
        sh '''
          set -euxo pipefail

          # Ensure TMPDIR exists (on disk) and is writable
          sudo mkdir -p "${TMPDIR}"
          sudo chown -R "$(id -un)":"$(id -gn)" "${TMPDIR}"

          if ! command -v terraform >/dev/null 2>&1; then
            echo "Terraform not found. Installing..."
            sudo dnf -y install unzip || true

            # Fix curl on AL2023 (curl-minimal conflict)
            if ! command -v curl >/dev/null 2>&1; then
              sudo dnf -y swap curl-minimal curl --allowerasing || sudo dnf -y install curl --allowerasing
            fi

            TF_VERSION="1.14.4"
            curl -fsSL -o "${TMPDIR}/terraform.zip" \
              "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip"

            unzip -o "${TMPDIR}/terraform.zip" -d "${TMPDIR}"
            sudo mv "${TMPDIR}/terraform" /usr/local/bin/terraform
            sudo chmod +x /usr/local/bin/terraform
          fi

          terraform version
        '''
      }
    }

    stage('Terraform Init') {
      steps {
        sh '''
          set -euxo pipefail
          mkdir -p "${TF_PLUGIN_CACHE_DIR}"
          cd "${ENV_DIR}"
          terraform init
        '''
      }
    }

    stage('Terraform Format & Validate') {
      steps {
        sh '''
          set -euxo pipefail
          cd "${ENV_DIR}"
          terraform fmt -check -recursive
          terraform validate
        '''
      }
    }

    stage('Terraform Plan') {
      steps {
        sh '''
          set -euxo pipefail
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
          set -euxo pipefail
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
        echo "Temp after run:"
        df -h /tmp || true
        df -h /opt/jenkins || true
      '''
      cleanWs()
      echo "Pipeline finished."
    }
  }
}
