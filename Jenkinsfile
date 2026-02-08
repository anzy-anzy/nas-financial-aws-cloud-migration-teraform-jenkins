pipeline {
  agent { label 'terraform' }

  environment {
    AWS_DEFAULT_REGION   = 'us-east-1'
    ENV_DIR              = 'envs/prod'
    TF_IN_AUTOMATION     = 'true'
    TF_INPUT             = 'false'

    // Put temp downloads/unzips on disk (NOT tmpfs)
    TMPDIR               = '/opt/jenkins/tmp'

    // Use a stable, shared plugin cache on disk
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

    stage('Prepare Cache & Temp Dirs') {
      steps {
        sh '''
          set -euxo pipefail

          # tmp dir for downloads
          sudo mkdir -p "${TMPDIR}"
          sudo chmod 1777 "${TMPDIR}"

          # terraform plugin cache (must be writable by the build user)
          sudo mkdir -p "${TF_PLUGIN_CACHE_DIR}"
          sudo chown -R "$(id -un)":"$(id -gn)" "${TF_PLUGIN_CACHE_DIR}"

          ls -ld "${TMPDIR}" "${TF_PLUGIN_CACHE_DIR}"
        '''
      }
    }

    stage('Detect Branch') {
      steps {
        script {
          // In a single Pipeline job, BRANCH_NAME may be empty.
          // This reads the actual checked-out branch name.
          env.GIT_BRANCH_NAME = sh(
            script: 'git rev-parse --abbrev-ref HEAD',
            returnStdout: true
          ).trim()

          // If Jenkins checked out a detached HEAD, try to resolve the remote branch
          if (env.GIT_BRANCH_NAME == 'HEAD') {
            env.GIT_BRANCH_NAME = sh(
              script: "git name-rev --name-only HEAD | sed 's#remotes/origin/##' | head -n1",
              returnStdout: true
            ).trim()
          }

          echo "Detected branch: ${env.GIT_BRANCH_NAME}"
        }
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
          echo "Temp (${TMPDIR}):"
          df -h "${TMPDIR}" || true
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
      when {
        expression { env.GIT_BRANCH_NAME == 'main' }
      }
      steps {
        timeout(time: 15, unit: 'MINUTES') {
          input message: "Apply Terraform changes to PROD?", ok: "Yes, Apply"
        }
      }
    }

    stage('Terraform Apply') {
      when {
        expression { env.GIT_BRANCH_NAME == 'main' }
      }
      steps {
        sh '''
          set -euxo pipefail
          cd "${ENV_DIR}"
          terraform apply -auto-approve tfplan
        '''
      }
    }

    stage('Non-main: Stop after plan') {
      when {
        expression { env.GIT_BRANCH_NAME != 'main' }
      }
      steps {
        echo "Not on main branch (${env.GIT_BRANCH_NAME}). Skipping apply (plan-only run)."
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
        df -h "${TMPDIR}" || true
        echo "Plugin cache dir:"
        du -sh "${TF_PLUGIN_CACHE_DIR}" || true
      '''
      cleanWs()
      echo "Pipeline finished."
    }
  }
}
