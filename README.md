# DevSecOps CI/CD Pipeline

## Architecture
![Architecture diagram](images/architecture-diagram.png)

## Features
- CI/CD automation
- Docker containerization
- AWS ECR image registry
- EC2 deployment via SSH
- Flask application with health checks

## How to run locally
docker build -t devsecops .
docker run -p 8080:8080 devsecops

## Endpoints
/ → App
/health → Health check

##
# DevSecOps Security Automation CI/CD Pipeline

## Project Summary

This project demonstrates the design and implementation of a secure, automated DevSecOps CI/CD pipeline that integrates security throughout the software development lifecycle (SDLC). Built using industry best practices, the pipeline automates code quality checks, security scanning, infrastructure deployment, and continuous monitoring to deliver applications securely, reliably, and efficiently.

### Key Highlights

* End-to-end CI/CD pipeline with integrated DevSecOps practices
* Automated static, dependency, container, and infrastructure security scanning
* Infrastructure as Code (Terraform/CloudFormation)
* Secure secrets management and least-privilege access controls
* Automated testing, build, deployment, and rollback capabilities
* Continuous monitoring, logging, and security alerting
* Designed following DevSecOps, Zero Trust, and cloud security best practices

### Skills Demonstrated

DevSecOps • CI/CD • GitHub Actions/Jenkins • Docker • Kubernetes • Terraform • AWS • Infrastructure as Code • SAST • DAST • Software Composition Analysis (SCA) • Container Security • IAM • Secrets Management • Security Automation • Continuous Monitoring • Cloud Security • DevOps

This project demonstrates hands-on experience building secure, automated deployment pipelines that integrate security into every stage of the development lifecycle, showcasing skills relevant to DevSecOps Engineer, Cloud Engineer, Site Reliability Engineer (SRE), Platform Engineer, and Cloud Security Engineer roles.
