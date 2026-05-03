# CI/CD Workshop Progress (Parts 1 and 2)

This document details the progress made in the workshop up to **Part 2** and serves as a starting point for you to continue with the Jenkins configuration and complete **Parts 3 and 4**.

## What has been done so far?

### 1. Defining the Pipeline and Advanced Flow (Jenkinsfile)
The `Jenkinsfile` file in the project root has been updated to meet the requirements of Parts 1 and 2:
- **Checkout**: Cloning the source code.
- **Build & Test**: Compiling and running tests using Maven (`mvn clean package`).
- **Static Analysis (SonarQube)**: Stage configured to send the static analysis to a local SonarQube container.
- **Docker Build & Security Scan (Trivy)**: Building the application’s Docker image (`mi-app:latest`) and automatically scanning for vulnerabilities using Trivy.
- **Deploy (Kubernetes)**: Instead of using `docker run`, the pipeline was adapted to inject variables into a Kubernetes template (`envsubst`) and deploy the application using `kubectl apply`.
- **Post Actions**: Automatic cleanup of the workspace (`cleanWs()`).

### 2. Environment Setup (Kubernetes and Containers)
Since we decided to use Kubernetes (K8s) instead of native Docker for deployment, the base infrastructure requires additional tools. This was automated to avoid installing tools manually:

*   **`k8s-config/deployment.tmpl.yml`**: The APIs were updated to the modern version (`apps/v1`), and `imagePullPolicy: Never` was configured so that K8s uses the image built by the pipeline locally. The service is exposed on port `30080` (NodePort).
*   **`Dockerfile.jenkins`**: A custom Jenkins image was created that automatically pre-installs:
    *   Docker CLI (to build the image).
    *   `kubectl` (to interact with the K8s cluster).
    *   `trivy` (for security scanning).
    *   `envsubst` (to render K8s manifests).
*   **`docker-compose.yml`**: Created to simultaneously start Jenkins (with access to the host machine’s K8s cluster) and the required SonarQube container.

---

## Next Steps (Your Turn - Parts 3 and 4)

The base environment is now built and running successfully on this machine, and the initial Jenkins configuration (Instance Configuration) has been completed.

### 1. Accessing Jenkins and SonarQube
The platforms are running locally. You can access them using the following credentials that have already been configured:

**Jenkins:**
* **URL:** [http://localhost:8080/jenkins](http://localhost:8080/jenkins)
* **Username:** `admin`
* **Password:** `admin`
* **Email:** `admin@test.com`

**SonarQube:**
* **URL:** [http://localhost:9000](http://localhost:9000)
* **Username:** `admin`
* **Password:** `admin123`

### 2. Install Additional Plugins
From Manage Jenkins > Plugins, make sure to install:
- **SonarQube Scanner**
- **Docker Pipeline**

### 3. Configure SonarQube (Requirement Part 3)
1. Go to `http://localhost:9000` (admin/admin), create a project named `my-app`, and generate a token.
2. In Jenkins, go to *Manage Jenkins > System* and add the SonarQube Server with the URL `http://sonarqube:9000` and the token as the credential.
3. Under *Manage Jenkins > Tools*, automatically install the SonarQube Scanner.

### 4. Create the Job and Run
1. Create a **Pipeline**-type job (“Pipeline script from SCM”) pointing to this repository.
2. Run the Job. It may **fail intentionally** due to “Quality Gates” if the code has technical debt or vulnerabilities detected by Trivy (you must fix the Jenkinsfile so that it fails if there are “CRITICAL” vulnerabilities, as required in Part 3).

### 5. Final Test and Deployment (Part 4)
Once the pipeline passes successfully:
1. Modify a file in the project (for example, in `src/main/resources/`).
2. Commit and push.
3. Watch as Jenkins redeploys to Kubernetes.
4. Go to `http://localhost:30080` to see your application running.

*(Don’t forget to take screenshots of the configuration and export the Job’s `config.xml` file upon completion for the deliverables).*
