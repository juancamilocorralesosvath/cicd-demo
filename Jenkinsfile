pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                echo 'Compilando y empaquetando la aplicacion...'
                // Arreglar permisos y saltos de linea (Windows a Linux)
                sh 'chmod +x mvnw'
                sh 'sed -i "s/\\r\$//" mvnw'
                sh './mvnw clean package -DskipTests'
            }
        }
        
        stage('Test') {
            steps {
                echo 'Ejecutando pruebas...'
                // Excluimos SeleniumExampleTest ya que requiere infraestructura externa (Selenium Grid)
                sh './mvnw test -DforkCount=0 -Dtest=!SeleniumExampleTest'
            }
        }

        stage('Static Analysis (SonarQube)') {
            steps {
                echo 'Ejecutando analisis de SonarQube...'
                script {
                    // Se usa withSonarQubeEnv para inyectar automáticamente el token configurado en Jenkins
                    withSonarQubeEnv('SonarQube') {
                        // Usamos la URL interna del servicio (sonarqube) para la comunicación entre contenedores
                        sh './mvnw sonar:sonar -Dsonar.projectKey=my-app -Dsonar.host.url=http://sonarqube:9000 -Dsonar.qualitygate.wait=true'
                    }
                }
            }
        }
        
        stage('Docker Build') {
            steps {
                echo 'Construyendo la imagen Docker...'
                sh 'docker build -t mi-app:latest .'
            }
        }

        stage('Container Security Scan (Trivy)') {
            steps {
                echo 'Escaneando la imagen Docker buscando vulnerabilidades conocidas...'
                // Se configura para que el pipeline falle si encuentra vulnerabilidades críticas en el sistema operativo base
                sh 'trivy image --vuln-type os --exit-code 1 --severity CRITICAL mi-app:latest'
            }
        }
        
        stage('Deploy (Kubernetes)') {
            when { 
                anyOf {
                    branch 'master'
                    expression { env.GIT_BRANCH == 'origin/master' || env.GIT_BRANCH == 'master' }
                }
            }
            environment {
                APP_NAME = 'mi-app'
            }
            steps {
                echo 'Desplegando la aplicacion en Kubernetes...'
                // Reemplazamos las variables y aplicamos el deployment
                // (Requiere que kubectl esté instalado en el agente de Jenkins y configurado)
                sh "envsubst < k8s-config/deployment.tmpl.yml > k8s-config/deployment.yml"
                sh 'kubectl apply -f k8s-config/deployment.yml --validate=false'
            }
        }
    }

    post {
        always {
            echo 'Limpiando entorno...'
            cleanWs() // Limpia el espacio de trabajo despues de cada ejecucion
        }
        failure {
            echo 'Pipeline failed due to quality or security violations.'
        }
    }
}
