# Avances del Taller CI/CD (Partes 1 y 2)

Este documento detalla el progreso realizado en el taller hasta la **Parte 2** y sirve como punto de partida para que puedas continuar con la configuración en Jenkins y completar las **Partes 3 y 4**.

## ¿Qué se ha realizado hasta ahora?

### 1. Definición del Pipeline y Flujo Avanzado (Jenkinsfile)
Se ha actualizado el archivo `Jenkinsfile` en la raíz del proyecto para cumplir con los requerimientos de las partes 1 y 2:
- **Checkout**: Clonación del código fuente.
- **Build & Test**: Compilación y ejecución de pruebas usando Maven (`mvn clean package`).
- **Static Analysis (SonarQube)**: Etapa configurada para enviar el análisis estático a un contenedor local de SonarQube.
- **Docker Build & Security Scan (Trivy)**: Construcción de la imagen Docker de la aplicación (`mi-app:latest`) y escaneo automático de vulnerabilidades usando Trivy.
- **Deploy (Kubernetes)**: En lugar de usar `docker run`, se adaptó el pipeline para inyectar variables en un template de Kubernetes (`envsubst`) y desplegar la aplicación mediante `kubectl apply`.
- **Post Actions**: Limpieza automática del espacio de trabajo (`cleanWs()`).

### 2. Preparación del Entorno (Kubernetes y Contenedores)
Dado que decidimos utilizar Kubernetes (K8s) en lugar de Docker nativo para el despliegue, la infraestructura base requiere herramientas adicionales. Se automatizó esto para no instalar herramientas a mano:

*   **`k8s-config/deployment.tmpl.yml`**: Se actualizaron las APIs a la versión moderna (`apps/v1`) y se configuró `imagePullPolicy: Never` para que K8s use la imagen construida por el pipeline localmente. El servicio está expuesto en el puerto `30080` (NodePort).
*   **`Dockerfile.jenkins`**: Se creó una imagen de Jenkins personalizada que preinstala automáticamente:
    *   Docker CLI (para construir la imagen).
    *   `kubectl` (para interactuar con el clúster de K8s).
    *   `trivy` (para el escaneo de seguridad).
    *   `envsubst` (para renderizar los manifiestos de K8s).
*   **`docker-compose.yml`**: Se creó para levantar simultáneamente Jenkins (con acceso al clúster K8s de la máquina host) y el contenedor de SonarQube requerido.

---

## Próximos pasos (Tu turno - Partes 3 y 4)

El entorno base ya está construido y corriendo exitosamente en esta máquina, y la configuración inicial de Jenkins (Instance Configuration) ya fue completada.

### 1. Acceso a Jenkins y SonarQube
Las plataformas están corriendo localmente. Puedes acceder con las siguientes credenciales que ya fueron configuradas:

**Jenkins:**
* **URL:** [http://localhost:8080/jenkins](http://localhost:8080/jenkins)
* **Usuario:** `admin`
* **Contraseña:** `admin`
* **Correo:** `admin@test.com`

**SonarQube:**
* **URL:** [http://localhost:9000](http://localhost:9000)
* **Usuario:** `admin`
* **Contraseña:** `admin123`

### 2. Instalar Plugins Adicionales
Desde Administrar Jenkins > Plugins, asegúrate de instalar:
- **SonarQube Scanner**
- **Docker Pipeline**

### 3. Configurar SonarQube (Requerimiento Parte 3)
1. Entra a `http://localhost:9000` (admin/admin), crea un proyecto llamado `my-app` y genera un Token.
2. En Jenkins, ve a *Administrar Jenkins > Sistema* y añade el Servidor SonarQube con la URL `http://sonarqube:9000` y el Token como credencial.
3. En *Administrar Jenkins > Tools*, instala automáticamente el SonarQube Scanner.

### 4. Crear el Job y Ejecutar
1. Crea un Job tipo **Pipeline** ("Pipeline script from SCM") apuntando a este repositorio.
2. Corre el Job. Es posible que **falle a propósito** debido a las "Puertas de Calidad" si el código tiene deuda técnica o vulnerabilidades detectadas por Trivy (deberás arreglar el Jenkinsfile para que falle si hay vulnerabilidades "CRITICAL", según pide la Parte 3).

### 5. Prueba Final y Despliegue (Parte 4)
Una vez que el pipeline pase en verde:
1. Modifica algún archivo del proyecto (por ejemplo en `src/main/resources/`).
2. Haz `commit` y `push`.
3. Observa cómo Jenkins redespliega en Kubernetes.
4. Entra a `http://localhost:30080` para ver tu aplicación corriendo.

*(No olvides tomar los pantallazos de la configuración y exportar el `config.xml` del Job al finalizar para los entregables).*
