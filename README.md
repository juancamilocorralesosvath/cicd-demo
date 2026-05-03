# CI/CD Pipeline Workshop - Final Project

This repository contains a full Continuous Integration and Continuous Deployment (CI/CD) pipeline built with Jenkins, SonarQube, Trivy, and Kubernetes. The project demonstrates the automation of building, testing, securing, and deploying a Spring Boot application.

## 🏗 Architecture & Infrastructure

The pipeline infrastructure runs entirely locally via Docker Compose and custom images:

1. **Jenkins (Master Node)**
   - Runs in a custom Docker container (`Dockerfile.jenkins`).
   - Pre-configured with Docker CLI, Kubectl, Trivy, and `envsubst`.
   - Access: `http://localhost:8080/jenkins`
2. **SonarQube**
   - Runs alongside Jenkins via `docker-compose.yml`.
   - Performs deep static code analysis.
   - Access: `http://localhost:9000`
3. **Local Kubernetes Cluster**
   - Uses the host machine's `~/.kube` configuration.
   - The application is deployed directly to the local cluster.

## 🚀 Pipeline Workflow (Jenkinsfile)

The Jenkins Declarative Pipeline is designed to be executed via **Pipeline script from SCM**. It executes the following distinct stages on every run:

1. **Checkout:** Clones the source code from the configured SCM repository.
2. **Build:** Compiles and packages the Spring Boot Java application using Maven (`./mvnw clean package -DskipTests`).
3. **Test:** Executes basic unit tests using Maven (`./mvnw test`).
4. **Static Analysis (SonarQube):** 
   - Sends the codebase to the local SonarQube server for code quality inspection.
   - **Gatekeeping:** The pipeline fails based on the SonarQube Quality Gate, which evaluates bugs, vulnerabilities, and security ratings.
5. **Docker Build:** 
   - Builds the Docker image `mi-app:latest` using the generated application artifact.
6. **Container Security Scan (Trivy):** 
   - Runs an Aqua Security Trivy scan on the built Docker image.
   - **Gatekeeping:** Fails the pipeline immediately if any `CRITICAL` severity vulnerabilities are found.
7. **Deploy (Kubernetes):** 
   - Only executes on the `main` branch.
   - Replaces environment variables in the K8s template using `envsubst`.
   - Applies the deployment configuration via `kubectl apply`. The application is exposed as a NodePort service on port `30080`.
   - Access: `http://localhost:30080`

**Note on Deployment Strategy:** While the original exercise suggested deploying via a simple `docker run -d -p 80:80 mi-app:latest`, this project uses **Kubernetes (K8s)** as an advanced alternative. Deploying via K8s demonstrates a production-grade infrastructure pattern and better integrates with the custom Jenkins environment built in `Dockerfile.jenkins`. However, the original fallback `docker run` command fully satisfies the deployment requirement if a simpler approach is desired.

**Post Actions:** 
- `always`: The workspace is cleaned up (`cleanWs()`) to ensure consistent state across runs.
- `failure`: Outputs clear failure logs indicating pipeline failures due to quality or security violations.

## ⚙️ Manual Configuration Guide

To replicate or evaluate this setup, the following configurations must be present in Jenkins:

### 1. Plugins
Ensure the following plugins are installed via *Manage Jenkins -> Plugins*:
- **SonarQube Scanner**
- **Docker Pipeline**

### 2. SonarQube Integration
1. Log into SonarQube (`admin`/`admin123`) at `http://localhost:9000`.
2. Create a project named `my-app` and generate an authentication token.
3. In Jenkins (*Manage Jenkins -> System*), add a **SonarQube Server**:
   - **Name:** `SonarQube`
   - **Server URL:** `http://sonarqube:9000`
   - **Credentials:** Add the token as a Secret Text credential.
4. Go to *Manage Jenkins -> Tools* and ensure SonarQube Scanner is set to auto-install.

### 3. Pipeline Job & Automation Trigger
1. Create a **Pipeline** job in Jenkins.
2. Select **Pipeline script from SCM**, point it to this Git repository, and specify `Jenkinsfile` as the Script Path.
3. To enable automatic deployments, configure a **Poll SCM** schedule (e.g., `* * * * *`) or set up a **GitHub Webhook** trigger under your job settings. This ensures the pipeline executes automatically on every code push.

## 🚦 Testing & Gatekeeping Validations

To validate the gatekeeping mechanisms, try the following:
* **Simulate Trivy Failure:** Modify the `Dockerfile` to use an insecure base image (like an outdated `alpine` or `node` version with known CVEs). Commit and push. The pipeline will fail at the Container Security Scan stage.
* **Simulate SonarQube Failure:** Introduce intentional technical debt or hardcode a password/secret in the Java source code to trigger a Security Hotspot. The pipeline will fail at the Static Analysis stage due to the Quality Gate.
* **Successful Deployment:** Resolve all vulnerabilities and hotspots. The pipeline will complete successfully, and the updated application will be visible at `http://localhost:30080`.