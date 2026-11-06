
pipeline {
    agent any

    environment {
        DOCKER_USER = 'karthikcls'
        IMAGE_NAME = 'python-jenkins-demo'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code'

                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing Python dependencies'

                sh '''
		   sudo  apt-get update
		   sudo  apt-get install -y python3.14-venv


		    rm -rf .venv
		    python3 -m venv .venv

                     . .venv/bin/activate
                    python -m pip install --upgrade pip


                    .venv/bin/pip install -r requirements.txt
                '''
            }
        }

        stage('Run Unit Tests') {
            steps {
                echo 'Running Python tests'

                sh '''
                    .venv/bin/python -m pytest tests/ -v
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image'

                sh """
                    docker build -t ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG} .
                    docker tag ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG} \
                        ${DOCKER_USER}/${IMAGE_NAME}:latest
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                echo 'Pushing image to Docker Hub'

                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        set +x
                        echo "$DOCKER_PASSWORD" | docker login \
                            -u "$DOCKER_USERNAME" --password-stdin

                        docker push "$DOCKER_USERNAME/python-jenkins-demo:$BUILD_NUMBER"
                        docker push "$DOCKER_USERNAME/python-jenkins-demo:latest"

                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying application to Kubernetes'

                withCredentials([
                    file(
                        credentialsId: 'kubeconfig-file',
                        variable: 'KUBECONFIG'
                    )
                ]) {
                    sh '''
                        kubectl apply -f k8s/

                        kubectl set image deployment/python-flask-app \
                          flask-app=$DOCKER_USER/python-jenkins-demo:$BUILD_NUMBER

                        kubectl rollout status \
                          deployment/python-flask-app \
                          --timeout=180s
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    kubectl get deployments
                    kubectl get pods
                    kubectl get services
                '''
            }
        }
    }

    post {
        success {
            echo 'CI/CD Pipeline completed successfully!'
        }

        failure {
            echo 'CI/CD Pipeline failed. Check Jenkins console output.'
        }

        always {
            echo 'Pipeline execution finished.'
        }
    }
}
