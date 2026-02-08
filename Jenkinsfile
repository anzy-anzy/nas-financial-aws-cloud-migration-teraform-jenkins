pipeline {
  agent { label 'terraform' }

  environment {
    AWS_DEFAULT_REGION   = 'us-east-1'
    ENV_DIR              = 'envs/prod'
    TF_IN_AUTOMATION     = 'true'
    TF_INPUT             = 'false'

    // Use disk-backed temp (you already bind-mounted /tmp, but this is fine too)
    TMPDIR               = '/opt/jenkins/tmp'

    // Persistent Terraform provider cache (survives cleanWs)
    TF_PLUGIN_CACHE_DIR  = '/opt/jenkins/tf-plugin-cache'
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
          echo "Temp (/tmp):"
          df -h /tmp || true
          echo "Temp (/opt/jenkins/tmp):"
          df -h /opt/jenkins/tmp || true
          java -version
          git --version
          terraform version || true
        '''
      }
    }

    stage('Prepare Cache & Temp Dirs') {
      steps {
        sh '''
          set -euxo pipefail

          # Temp dir on disk
          sudo mkdir -p "${TMPDIR}"
          sudo chmod 1777 "${TMPDIR}"

          # Persistent plugin cache (providers)
          sudo mkdir -p "${TF_PLUGIN_CACHE_DIR}"
          sudo chown -R "$(id -un)":"$(id -gn)" "${TF_PLUGIN_CACHE_DIR}"

          ls -ld "${TMPDIR}" "${TF_PLUGIN_CACHE_DIR}"
        '''
      }
    }

    stage('Install Terraform (if missing)') {
      steps {
        sh '''
          set -euxo pipefail

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
        df -h /opt/jenkins/tmp || true
        echo "Plugin cache dir:"
        du -sh /opt/jenkins/tf-plugin-cache || true
      '''
      cleanWs()
      echo "Pipeline finished."
    }
  }
}
