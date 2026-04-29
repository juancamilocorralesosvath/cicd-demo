pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                // Obtener el código fuente desde el repositorio configurado
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                echo 'Compilando la aplicación...'
                // Usamos el wrapper de Maven que viene en el proyecto
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
                echo 'Ejecutando pruebas...'
                sh './mvnw test'
            }
        }
    }
}
