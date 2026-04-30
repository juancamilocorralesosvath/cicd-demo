pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build & Test') {
            steps {
                echo 'Compilando la aplicacion y ejecutando pruebas...'
                // Arreglar permisos y saltos de linea (Windows a Linux)
                sh 'chmod +x mvnw'
                sh 'sed -i "s/\\r\$//" mvnw'
                sh './mvnw clean package'
            }
        }

        stage('Static Analysis (SonarQube)') {
            steps {
                echo 'Ejecutando analisis de SonarQube...'
                script {
                    // Requiere el plugin de SonarQube instalado en Jenkins y el servidor corriendo
                    sh './mvnw sonar:sonar -Dsonar.projectKey=my-app -Dsonar.host.url=http://sonarqube:9000'
                }
            }
        }
        
        stage('Docker Build & Security Scan (Trivy)') {
            steps {
                echo 'Construyendo la imagen Docker y escaneando...'
                sh 'docker build -t mi-app:latest .'
                // Escanea la imagen Docker buscando vulnerabilidades conocidas
                sh 'trivy image mi-app:latest'
            }
        }
        
        stage('Deploy (Kubernetes)') {
            when { branch 'main' }
            steps {
                echo 'Desplegando la aplicacion en Kubernetes...'
                // Configuramos las variables de entorno para reemplazar en el template
                env.APP_NAME = 'mi-app'
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
            echo 'La ejecucion del pipeline ha fallado. Revisa los logs.'
        }
    }
}
