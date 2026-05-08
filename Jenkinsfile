pipeline {
    agent any

    environment {
        APP_NAME       = 'ecommerce-app'
        DOCKERHUB_USER = credentials('DOCKERHUB_USER')   // set in Jenkins credentials
        DOCKERHUB_TOKEN= credentials('DOCKERHUB_TOKEN')  // set in Jenkins credentials
    }

    triggers {
        // Auto-trigger on GitHub webhook push
        githubPush()
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_SHA    = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    env.GIT_BRANCH = env.BRANCH_NAME ?: sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
                    // Determine Docker Hub repo based on branch
                    env.DOCKER_REPO = (env.GIT_BRANCH == 'master' || env.GIT_BRANCH == 'main') ? 'prod' : 'dev'
                    env.IMAGE_TAG   = "${DOCKERHUB_USER}/${env.DOCKER_REPO}:${env.GIT_SHA}"
                    env.IMAGE_LATEST= "${DOCKERHUB_USER}/${env.DOCKER_REPO}:latest"
                    echo "Branch: ${env.GIT_BRANCH} → Repo: ${env.DOCKER_REPO}"
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm ci --silent'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build \\
                      -t ${APP_NAME}:latest \\
                      -t ${env.IMAGE_TAG} \\
                      -t ${env.IMAGE_LATEST} \\
                      .
                """
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    def cid = sh(script: "docker run -d --rm -p 8099:80 ${APP_NAME}:latest", returnStdout: true).trim()
                    sleep 3
                    def status = sh(script: "curl -s -o /dev/null -w '%{http_code}' http://localhost:8099", returnStdout: true).trim()
                    sh "docker stop ${cid} || true"
                    if (status != '200') {
                        error "Smoke test FAILED – HTTP ${status}"
                    }
                    echo "Smoke test passed – HTTP ${status}"
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                sh "echo ${DOCKERHUB_TOKEN} | docker login -u ${DOCKERHUB_USER} --password-stdin"
                sh "docker push ${env.IMAGE_TAG}"
                sh "docker push ${env.IMAGE_LATEST}"
                echo "Pushed to ${env.DOCKER_REPO} repo on Docker Hub"
            }
        }

        stage('Deploy to Server') {
            // Only deploy when pushing to dev or master
            when {
                anyOf {
                    branch 'dev'
                    branch 'master'
                    branch 'main'
                }
            }
            steps {
                sh """
                    docker rm -f ${APP_NAME} || true
                    docker run -d \\
                      --name ${APP_NAME} \\
                      --restart unless-stopped \\
                      -p 80:80 \\
                      ${env.IMAGE_LATEST}
                """
                echo "Deployed ${env.IMAGE_LATEST} on port 80"
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline SUCCESS – ${env.IMAGE_TAG} deployed"
        }
        failure {
            echo "❌ Pipeline FAILED – check logs above"
        }
        always {
            sh 'docker logout || true'
        }
    }
}
