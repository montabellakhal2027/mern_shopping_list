pipeline {
    agent any
    
    environment {
        DOCKER_BUILDKIT = '0'
        COMPOSE_DOCKER_CLI_BUILD = '0'
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                script {
                    git branch: 'main', 
                        credentialsId: '57003460-4ba9-4eb9-8783-e61d76c446c1', 
                        url: 'https://github.com/montabellakhal2027/mern_shopping_list'
                    sh 'ls -la'
                    sh 'pwd'
                }
            }
        }
        
        stage('Start Minikube') {
            steps {
                script {
                    sh 'minikube delete || true'
                    sh 'minikube cache delete || true'
                    sh 'free -h'
                    sh 'df -h'
                    sh 'minikube config set driver docker'
                    sh 'minikube config set cpus 2'
                    sh 'minikube config set memory 4096'
                    sh '''
                        minikube start \
                            --driver=docker \
                            --cpus=2 \
                            --memory=4096 \
                            --disk-size=20g \
                            --kubernetes-version=v1.28.3 \
                            --wait=apiserver,system_pods \
                            --wait-timeout=10m \
                            --delete-on-failure \
                            --force
                    '''
                    sh 'sleep 60'
                    sh 'minikube status'
                    sh 'kubectl config use-context minikube'
                    sh 'kubectl get nodes'
                    sh 'kubectl get pods --all-namespaces'
                }
            }
        }
        
        stage('Build Backend') {
            steps {
                script {
                    sh 'ls -la'
                    sh 'find . -name "Dockerfile" -type f'
                    sh '''
                        echo "Testing DNS resolution..."
                        nslookup registry.npmjs.org || echo "DNS resolution failed"
                        ping -c 3 registry.npmjs.org || echo "Ping failed"
                    '''
                    
                    withCredentials([usernamePassword(
                        credentialsId: '0fd0d612-631a-42d0-9d3d-20918d97446f', 
                        usernameVariable: 'DOCKER_USER', 
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh '''
                            echo "Logging into Docker Hub..."
                            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                            export DOCKER_BUILDKIT=0
                            docker build --network=host -t monta2027/mern:latest .
                            docker push monta2027/mern:latest
                        '''
                    }
                }
            }
        }
        
        stage('Build Frontend') {
            steps {
                script {
                    sh 'ls -la client/ || echo "client directory not found"'
                    
                    withCredentials([usernamePassword(
                        credentialsId: '0fd0d612-631a-42d0-9d3d-20918d97446f', 
                        usernameVariable: 'DOCKER_USER', 
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh '''
                            echo "Logging into Docker Hub..."
                            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                            export DOCKER_BUILDKIT=0
                            docker build --network=host -t monta2027/mern-frontend:latest client
                            docker push monta2027/mern-frontend:latest
                        '''
                    }
                }
            }
        }
          stage('Terraform with LocalStack') {
            steps {
                script {
                    // Start LocalStack
                    sh '''
                        docker stop localstack || true
                        docker rm localstack || true
                        docker run -d --name localstack \
                            --network=host \
                            -e SERVICES=s3 \
                            localstack/localstack
                        sleep 15
                    '''
                    
                    // Configure AWS CLI
                    sh '''
                        aws configure set aws_access_key_id test
                        aws configure set aws_secret_access_key test
                        aws configure set region us-east-1
                    '''
                    
                    // Terraform operations
                    sh 'terraform init -input=false'
                    sh 'terraform validate'
                    sh 'terraform plan -out=tfplan'
                    sh 'terraform apply -auto-approve tfplan'
                    
                    // Cleanup
                    sh 'docker stop localstack || true'
                }
            }
        }

        stage('Kubernetes Deployment') {
            steps {
                script {
                    // Verify service.yaml exists
                    if (!fileExists('service.yaml')) {
                        error "service.yaml not found"
                    }
                    
                    // Apply Kubernetes configuration
                    sh 'kubectl apply -f service.yaml'
                    
                    // Verify deployment
                    sh '''
                        kubectl rollout status deployment/mern --timeout=2m
                        kubectl get pods -o wide
                        kubectl get services
                    '''
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh """
                        sonar-scanner \
                          -Dsonar.projectKey=montabellakhal2027_mern_shopping_list_daae3eae-1685-4d7f-888d-15df4adf0426 \
                          -Dsonar.projectName="MERN Shopping List" \
                          -Dsonar.sources=. \
                          -Dsonar.host.url=http://localhost:9000 \
                          -Dsonar.login=\${SONAR_AUTH_TOKEN} \
                          -Dsonar.projectVersion=1.0 \
                          -Dsonar.scm.disabled=true \
                          -Dsonar.sourceEncoding=UTF-8 \
                          -X
                    """
                }
            }
        }
        
        stage('Push to GitHub') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: '57003460-4ba9-4eb9-8783-e61d76c446c1', 
                        usernameVariable: 'GIT_USERNAME', 
                        passwordVariable: 'GIT_PASSWORD'
                    )]) {
                        sh '''
                            git config user.email "monta.bellakhal10@gmail.com"
                            git config user.name "montabellakhal2027"
                            
                            if git diff --quiet && git diff --cached --quiet; then
                                echo "No changes to commit"
                            else
                                git add .
                                git commit -m "Automated commit by Jenkins"
                                git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/montabellakhal2027/mern_shopping_list.git main
                            fi
                        '''
                    }
                }
            }
        }
    }
    
    post {
        always {
            sh 'minikube delete || true'
            cleanWs()
        }
    }
}
