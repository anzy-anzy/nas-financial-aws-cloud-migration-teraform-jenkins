pipeline {
  agent { label 'terraform' }

  environment {
    AWS_DEFAULT_REGION   = 'us-east-1'
    ENV_DIR              = 'envs/prod'
    TF_IN_AUTOMATION     = 'true'
    TF_INPUT             = 'false'
    TMPDIR               = '/opt/jenkins/tmp'
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
          sudo mkdir -p "${TMPDIR}"
          sudo chmod 1777 "${TMPDIR}"
          sudo mkdir -p "${TF_PLUGIN_CACHE_DIR}"
          sudo chown -R "$(id -un)":"$(id -gn)" "${TF_PLUGIN_CACHE_DIR}"
          ls -ld "${TMPDIR}" "${TF_PLUGIN_CACHE_DIR}"
        '''
      }
    }

    stage('Tools Check') {
      steps {
        sh '''
          set -euxo pipefail
          df -h
          df -h /tmp || true
          df -h "${TMPDIR}" || true
          java -version
          git --version
          terraform version || true
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
        branch 'main'
      }
      steps {
        timeout(time: 15, unit: 'MINUTES') {
          input message: "Apply Terraform changes to PROD (main only)?", ok: "Yes, Apply"
        }
      }
    }

    stage('Terraform Apply') {
      when {
        branch 'main'
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
        not { branch 'main' }
      }
      steps {
        echo "Not on main branch. Skipping apply (plan-only run)."
      }
    }
  }

  post {
    always {
      sh '''
        set +e
        df -h
        df -h /tmp || true
        df -h "${TMPDIR}" || true
        du -sh "${TF_PLUGIN_CACHE_DIR}" || true
      '''
      cleanWs()
    }
  }
}
