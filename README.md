**DevOps Build & Deployment Pipeline for React Application**

**## Project Overview**

This project demonstrates a complete DevOps implementation for deploying a React application in a production-ready environment.

The application is containerized using Docker, automated using Jenkins CI/CD, deployed on an AWS EC2 instance, and monitored using an open-source monitoring solution.

**The complete workflow includes:**

- Docker containerization
- Docker Compose deployment
- Bash automation
- Git branching strategy
- AWS ECR image manangement
- Jenkins CI/CD pipeline
- AWS EC2 deployment
- Application monitoring
- GitHub version control

---

**## Original Repository**

Application Source

https://github.com/sriram-R-krishnan/devops-build

---

**# Tech Stack**

- React
- Docker
- Docker Compose
- Bash
- Git
- GitHub
- AWS ECR
- Jenkins
- AWS EC2
- Ubuntu
- Nginx (Port 80)
- Uptime Kuma (Monitoring)

---

**# Project Architecture**

GitHub (Dev Branch)
|
v
Jenkins Auto Trigger
|
v
Docker Build
|
v
AWS ECR (Dev Repo)
|
v
Deploy to AWS EC2

**After Merge**

Dev → Master
|
v
Jenkins Trigger
|
v
Docker Build
|
v
AWS ECR (Private Prod Repo)
|
v
Production Deployment

---

**# Project Structure**

devops-build/
│
├── Dockerfile
├── docker-compose.yml
├── build.sh
├── deploy.sh
├── .dockerignore
├── .gitignore
├── Jenkinsfile
├── README.md
└── src/

---

**# Prerequisites**

Before running this project install

- Git
- Docker
- Docker Compose
- Jenkins
- AWS CLI
- Ubuntu Server
- AWS ECR
