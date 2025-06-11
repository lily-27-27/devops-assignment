# 📦 DevOps Assignment – Full Stack Setup (Java, Terraform, CI/CD, Monitoring)

## 🔧 Tech Stack

- **Source Control**: GitHub, Git CLI
- **CI/CD**: GitLab CI
- **Infrastructure**: Terraform (AWS)
- **Containerization**: Docker
- **Database**: MySQL
- **Monitoring**: Prometheus + Grafana

---

## 📑 Contents

- [Project Overview](#project-overview)
- [Architecture Diagram](#architecture-diagram)
- [Step-by-step Setup](#step-by-step-setup)
  - [1. Clone and Prepare](#1-clone-and-prepare)
  - [2. Infrastructure Provisioning (Terraform)](#2-infrastructure-provisioning-terraform)
  - [3. Dockerize and CI/CD (GitLab)](#3-dockerize-and-cicd-gitlab)
  - [4. Database Migration](#4-database-migration)
  - [5. Monitoring with Prometheus and Grafana](#5-monitoring-with-prometheus-and-grafana)
- [Rollback Strategy](#rollback-strategy)
- [Challenges and Solutions](#challenges-and-solutions)

---

## 🧭 Project Overview

This project showcases a complete DevOps pipeline setup with IaC, CI/CD, database management, and monitoring. The core application is a Java web app deployed via Docker, with infrastructure provisioned using Terraform on AWS.

---

## 🗺️ Architecture Diagram

```plaintext
                    +-----------------------------+
                    |       GitHub Repository     |
                    +-------------+---------------+
                                  |
                                  v
                   +-----------------------------+
                   |       GitLab CI/CD          |
                   +-----------------------------+
                            |       |
                            v       v
         +--------------------+    +--------------------+
         |    Docker Image    |    |    Terraform IaC   |
         +---------+----------+    +---------+----------+
                   |                       |
                   v                       v
        +------------------+      +----------------------+
        |  Java Web App    |      |   AWS Infrastructure |
        +------------------+      +----------------------+
                   |
                   v
        +------------------+
        |   MySQL DB       |
        +------------------+
                   |
                   v
        +------------------+
        |Prometheus Exporter|
        +------------------+
                   |
                   v
           +-----------------+
           |    Grafana      |
           +-----------------+

Step-by-step Setup
1. Clone and Prepare
git clone https://github.com/lily-27-27/devops-assignment.git
cd devops-assignment

Install Terraform, Docker, and required tools.

2. Infrastructure Provisioning (Terraform)
cd infra/
terraform init
terraform plan
terraform apply

AWS EC2 for the app

Security groups

VPC (if needed)

Note: .terraform/ is excluded from the repository using .gitignore to avoid pushing large binaries.

3. Dockerize and CI/CD (GitLab)
Your java-web-app is Dockerized:

cd java-app/java-web-app
docker build -t java-web-app .
docker run -p 8080:8080 java-web-app

The .gitlab-ci.yml handles:

Building the Docker image

Running tests

Pushing to Docker registry

Deploying to the provisioned instance

You can place this file in the root of your repo.


4. Database Migration

cd db/migrations
psql -U <user> -d <dbname> -h <host> -f 001_create_users_table.sql
psql -U <user> -d <dbname> -h <host> -f 002_add_email_index.sql



5. Monitoring with Prometheus + Grafana
 -Prometheus pulls metrics from your app (use micrometer/actuator or exporter)
 -Grafana is configured to display dashboards

Steps:

Start Prometheus and Grafana via Docker Compose.

Add Prometheus as a Grafana datasource.

Import dashboards.

docker-compose up -d



🔁 Rollback Strategy
| Component    | Strategy                                            |
| ------------ | --------------------------------------------------- |
| Terraform    | Use `terraform destroy` or versioned state rollback |
| Docker Image | Tag with version numbers, redeploy stable tag       |
| Database     | Maintain `down` SQL scripts       |
| CI/CD        | Revert pipeline changes via Git                     |


🚧 Challenges and Solutions
| **Challenge**                                  | **How it was Handled**                                                          |
| ---------------------------------------------- | ------------------------------------------------------------------------------- |
| `.terraform/` too large to push                | Used `.gitignore`, removed with `git filter-repo`                               |
| Git LFS error for Terraform provider binary    | Rewrote history and removed large files                                         |
| Accidentally treated app folder as a submodule | Used `git rm --cached` and re-added as regular folder                           |
| Grafana not pulling Prometheus data            | Fixed Prometheus scrape config and updated Grafana datasource                   |
| Pushing to GitHub failed due to file > 100MB   | Used `git filter-repo` with `--force` to clean history                          |
| Missing files after force-push                 | Re-added from working directory and recommitted                                 |
| Migrating MySQL DB safely                      | Used versioned SQL scripts and tested on local instance before applying on prod |

✅ Conclusion
You now have a fully working DevOps stack that:

Provisions cloud infra with Terraform

Deploys apps with Docker and GitLab CI

Applies version-controlled DB migrations

Monitors system health using Grafana and Prometheus


