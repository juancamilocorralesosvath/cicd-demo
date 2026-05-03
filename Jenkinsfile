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
                sh './mvnw test -DforkCount=0'
            }
        }

        stage('Static Analysis (SonarQube)') {
            steps {
                echo 'Ejecutando analisis de SonarQube...'
                script {
                    // Requiere el plugin de SonarQube instalado en Jenkins y el servidor corriendo
                    // Se usa sonar.qualitygate.wait=true para que el pipeline falle si el Quality Gate no pasa
                    sh './mvnw sonar:sonar -Dsonar.projectKey=my-app -Dsonar.host.url=http://sonarqube:9000 -Dsonar.qualitygate.wait=true'
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
                // Se configura para que el pipeline falle si encuentra vulnerabilidades críticas
                sh 'trivy image --exit-code 1 --severity CRITICAL mi-app:latest'
            }
        }
        
        stage('Deploy (Kubernetes)') {
            when { branch 'main' }
            environment {
                APP_NAME = 'mi-app'
            }
            steps {
                echo 'Desplegando la aplicacion en Kubernetes...'
                // Reemplazamos las variables y aplicamos el deployment
                // (Requiere que kubectl esté instalado en el agente de Jenkins y configurado)
                sh 'envsubst < k8s-config/deployment.tmpl.yml > k8s-config/deployment.yml'
                sh 'kubectl apply -f k8s-config/deployment.yml'
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
