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
                echo 'Compilando la aplicacion...'
                // Arreglar permisos y saltos de linea (Windows a Linux)
                sh 'chmod +x mvnw'
                sh 'sed -i "s/\\r\$//" mvnw'
                sh './mvnw clean package -DskipTests'
            }
        }
        
        stage('Docker Build') {
            steps {
                echo 'Construyendo la imagen Docker...'
                sh 'docker build -t mi-app:latest .'
            }
        }
        
        stage('Test') {
            steps {
                echo 'Ejecutando pruebas basicas...'
                sh './mvnw test'
            }
        }
    }
}
