# Pipeline Design and Construction Exercise
## Prerequisites:
- Jenkins in Docker: docker run -p 8080:8080 -p 50000:50000 -v
jenkins_home:/var/jenkins_home jenkins/jenkins:lts
- Configuration: Start Jenkins and install the suggested plugins (Git, Pipeline, Docker)
- Project: Use a local repository or one on GitHub with simple code
- Suggested repository: https://github.com/helderklemp/cicd-demogithub

- Pipeline Definition (30%)
- Creating the Jenkinsfile: In the root of your project, create a file
named Jenkinsfile
- Stages: Define the declarative pipeline with the following stages:
- Checkout: Retrieve the source code from your repository.
- Build: Run the command to compile your application (e.g., npm install, mvn
package).
- Docker Build: Build the Docker image: docker build -t my-app:latest
- Test: Run basic tests to validate the result.
- Integration: Configure your Jenkins pipeline to read
this Jenkinsfile directly from the repository (Pipeline script from
SCM).jenkins+1
- Advanced Pipeline Flow (Jenkinsfile)
Extend your Jenkinsfile by including stages that validate quality and security before
deployment:
groovy
pipeline {
agent any
stages {
stage(‘Checkout’) {

steps {
git ‘https://github.com/helderklemp/cicd-demo.git’
}
}
stage(‘Build & Test’) {
steps {
sh ‘mvn clean package’ // Compile and run unit tests
automatically
}
}
stage(‘Static Analysis (SonarQube)’) {
steps {
// Requires the SonarQube plugin installed in jenkins
script {
sh 'mvn sonar:sonar -Dsonar.projectKey=my-app -
Dsonar.host.url=http://sonarqube:9000'
}
}
}
stage(‘Container Security Scan (Trivy)’) {
steps {
// Scan the Docker image for known vulnerabilities
sh ‘docker build -t my-app:latest .’
sh ‘trivy image my-app:latest’
}
}
stage(‘Deploy’) {

when { branch ‘main’ }
steps {
sh ‘docker run -d -p 8080:8080 my-app:latest’
}
}
}
post {
always {
echo ‘Cleaning up environment...’
cleanWs() // Cleans the workspace after each run
}
}
}
- Additional Steps for the Exercise (40%)
- Static Analysis (20 min): Set up a local SonarQube container to
integrate the code analysis stage into your pipeline.
- Security Scan (20 min): Install Trivy on your Jenkins agent and add the
vulnerability scanning stage to the Docker image.
- Gatekeeping (20 min): Modify the Pipeline so that the
deployment automatically fails if SonarQube detects a “Security Hotspot” or if
Trivy finds “CRITICAL” level vulnerabilities.
- Cleanup and Infrastructure (30 min): Ensure that the post-build block leaves the
containers in a consistent state and document the workflow process in a
README file.

- Deployment and Validation (30%)
- Deployment: Add a final Deploy stage that runs the newly created container
on your local machine: docker run -d -p 80:80 mi-app:latest .

- Refinement: Make sure the pipeline handles errors by using the
post { failure { ... } } block to receive notifications in case of failure.
- Final test: Make a change to your application’s code (e.g., an index.html file,
code with technical debt, insecure code), commit and push it to the repository, and
observe how Jenkins detects the change, builds the image, and deploys the new
version automatically if it passes the included validations.
By completing this exercise on your own (not using AI), you will have gone through the
complete cycle of designing and building a deployment flow, understanding how
automation reduces manual intervention and improves the reliability of the software
lifecycle.
## Deliverables:
- Export of the job(s) defined in Jenkins
- Screenshots of the configuration
- Results of the pipeline execution and application execution
- Modified source code

