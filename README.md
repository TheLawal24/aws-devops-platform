# AWS Multi-Environment DevOps Platform

[![Terraform CI](https://github.com/TheLawal24/aws-devops-platform/actions/workflows/terraform-ci.yml/badge.svg)](https://github.com/TheLawal24/aws-devops-platform/actions/workflows/terraform-ci.yml)
[![DevSecOps Security](https://github.com/TheLawal24/aws-devops-platform/actions/workflows/devsecops-security.yml/badge.svg)](https://github.com/TheLawal24/aws-devops-platform/actions/workflows/devsecops-security.yml)

A production-style AWS DevOps platform built with **Terraform, Amazon ECS/Fargate, Amazon ECR, Application Load Balancer, GitHub Actions, OpenID Connect (OIDC), CloudWatch, SNS, Trivy, Checkov, Semgrep, and Gitleaks**.

The project demonstrates a complete cloud delivery lifecycle:

**Infrastructure as Code → Build → Security Scan → Staging Deployment → Validation → Production Approval → Production Deployment → Monitoring → Rollback**

---

## Project Overview

This project provisions and operates a multi-environment container platform on AWS.

It was designed to demonstrate practical DevOps and DevSecOps engineering concepts including:

- Infrastructure as Code with Terraform
- Remote Terraform state
- AWS IAM least privilege
- GitHub Actions OIDC authentication
- Containerized application delivery
- Amazon ECS on Fargate
- Amazon ECR
- Application Load Balancing
- Staging-to-production promotion
- Immutable image deployment
- Vulnerability scanning
- Static application security testing
- Infrastructure security scanning
- Secrets scanning
- CloudWatch monitoring and alerting
- Deployment rollback
- Branch protection and controlled infrastructure changes

---

## Architecture

```mermaid
flowchart TD

    DEV[Developer]
    GH[GitHub Repository]
    CI[GitHub Actions CI/CD]
    OIDC[AWS IAM OIDC]
    ECR[Amazon ECR]

    ALB[Application Load Balancer]

    STAGE[Staging ECS Service]
    PROD[Production ECS Service]

    CW[Amazon CloudWatch]
    SNS[Amazon SNS]

    TF[Terraform]
    S3[Remote Terraform State - S3]

    DEV --> GH
    GH --> CI

    CI --> OIDC
    OIDC --> ECR

    CI --> STAGE
    CI --> PROD

    ALB --> STAGE
    ALB --> PROD

    STAGE --> CW
    PROD --> CW

    CW --> SNS

    TF --> S3
    TF --> OIDC
    TF --> ALB
    TF --> STAGE
    TF --> PROD
Technology Stack
Area	Technology
Cloud	AWS
Infrastructure as Code	Terraform
Containers	Docker
Container Registry	Amazon ECR
Container Runtime	Amazon ECS Fargate
Load Balancing	Application Load Balancer
CI/CD	GitHub Actions
Authentication	GitHub OIDC / AWS IAM
Monitoring	Amazon CloudWatch
Alerting	Amazon SNS
Secrets Scanning	Gitleaks
SAST	Semgrep
IaC Security	Checkov
Vulnerability Scanning	Trivy
Application	Python / Flask / Gunicorn
AWS Infrastructure

The platform provisions:

Custom VPC
Public and private subnets across multiple Availability Zones
Internet Gateway
Route tables
Application Load Balancer
Security groups
Amazon ECS cluster
Production ECS service
Staging ECS service
ECS task definitions
Amazon ECR repository
IAM execution and task roles
GitHub Actions deployment roles
GitHub OIDC provider
CloudWatch log groups
CloudWatch alarms
SNS alert topic
Remote Terraform state in Amazon S3
Application Architecture

The application is a lightweight Python service served with Gunicorn.

Endpoints include:

/

Application information and health status.

/health

Used by the Application Load Balancer and deployment pipeline for health validation.

The application listens internally on:

8080
Container Security

The application container follows several container-hardening practices.

The container:

Uses a minimal Python base image
Runs as a dedicated non-root user
Uses Gunicorn instead of the Flask development server
Uses immutable image versions in deployment pipelines
Is scanned for vulnerabilities before promotion

Example security model:

RUN addgroup --system appgroup \
    && adduser --system --ingroup appgroup appuser

USER appuser
CI/CD Pipeline

Application deployment follows a controlled promotion process.

Push to main
      │
      ▼
Build Docker image
      │
      ▼
Tag image with Git commit SHA
      │
      ▼
Push image to Amazon ECR
      │
      ▼
Security / vulnerability scan
      │
      ▼
Deploy SAME immutable image to staging
      │
      ▼
Wait for ECS stability
      │
      ▼
Run staging health check
      │
      ▼
Production environment approval
      │
      ▼
Deploy SAME SHA to production
      │
      ▼
Verify ECS stability and application health

The production deployment therefore promotes the exact artifact that successfully passed staging.

Immutable Deployments

Container images are identified using the Git commit SHA rather than mutable deployment tags.

Example:

808935753572.dkr.ecr.eu-west-2.amazonaws.com/aws-devops-platform-dev:<git-sha>

This improves:

Traceability
Rollback capability
Deployment auditing
Reproducibility
Staging and Production

The platform contains separate ECS services for:

Staging
Production

Both use the same ECS cluster and Application Load Balancer while maintaining separate:

ECS services
Task definitions
Target groups
Log groups
Deployment lifecycle

Production deployment occurs only after staging has successfully passed health verification.

GitHub Actions OIDC

The CI/CD pipeline does not rely on long-lived AWS access keys.

GitHub Actions authenticates to AWS using:

GitHub Actions
      │
      ▼
GitHub OIDC token
      │
      ▼
AWS IAM trust policy
      │
      ▼
Temporary AWS credentials

Trust policies restrict access according to repository, branch, and GitHub environment.

Separate IAM roles are used for:

Terraform CI
Terraform Apply
Application deployment

This separates infrastructure and application deployment responsibilities.

Terraform Remote State

Terraform state is stored remotely in Amazon S3.

S3 Bucket:
aws-devops-platform-tfstate-808935753572-eu-west-2

State:
aws-devops-platform/dev/terraform.tfstate

The backend uses:

S3 encryption
Bucket public-access blocking
Versioning
Native Terraform S3 state locking

Example:

use_lockfile = true

This prevents simultaneous Terraform operations from corrupting infrastructure state.

Terraform Delivery Workflow

Infrastructure changes follow:

Feature branch
      │
      ▼
Pull Request
      │
      ▼
Terraform Validate and Plan
      │
      ▼
Branch protection
      │
      ▼
Merge to main
      │
      ▼
Controlled Terraform Apply
      │
      ▼
Infrastructure environment approval
      │
      ▼
Post-apply drift verification

Direct changes to the protected main branch are prevented by repository rules.

DevSecOps Pipeline

Security scanning is integrated directly into GitHub Actions.

The pipeline uses four security tools:

Gitleaks

Scans Git history and source code for exposed secrets.

Gitleaks → BLOCKING

A detected credential prevents the security pipeline from succeeding.

Semgrep

Performs Static Application Security Testing.

Semgrep → BLOCKING

The application was hardened until the current Semgrep scan reached:

0 security findings
Checkov

Scans Terraform for infrastructure security misconfigurations.

Checkov → security baseline / reporting

Findings are evaluated according to architecture and risk rather than blindly remediated.

Trivy

Used for:

Vulnerability scanning
Secret scanning
Terraform configuration scanning
Container security analysis
Trivy → security baseline / reporting

Security reports are retained as GitHub Actions artifacts for review.

Security Hardening

Security improvements implemented during the project include:

Container hardening
Root container
      ↓
Non-root application user
ALB malformed-header protection
drop_invalid_header_fields = true
ALB deletion protection
enable_deletion_protection = true
Restricted ALB egress

Instead of unrestricted outbound access, the Application Load Balancer is restricted to application traffic toward the ECS security group.

ALB Security Group
       │
       │ TCP 8080
       ▼
ECS Security Group
IAM least privilege

Terraform's infrastructure role was hardened to reduce the blast radius of CI/CD credentials.

For example:

iam:PassRole

is restricted to the ECS execution/task roles rather than all IAM roles.

Security Risk Management

Not every scanner finding should automatically result in an infrastructure change.

Some findings are intentionally documented as architectural decisions in this learning environment.

Examples include:

Public-facing ALB
HTTP listener used for the current lab
ECS public networking in the no-NAT architecture
Selected encryption and advanced logging controls deferred as future production enhancements

This project demonstrates the DevSecOps workflow:

Detect
  ↓
Understand
  ↓
Assess architecture
  ↓
Remediate or document
  ↓
Validate
  ↓
Rescan

rather than changing infrastructure purely to achieve a zero-finding scanner result.

Monitoring and Alerting

The platform uses Amazon CloudWatch and SNS.

Implemented alarms include:

Unhealthy ALB targets
ALB target HTTP 5XX responses
High ECS CPU utilization
High ECS memory utilization

Alerts are delivered through Amazon SNS.

An end-to-end alarm test was performed by forcing a CloudWatch alarm into the ALARM state and verifying SNS notification delivery.

Deployment Safety

The ECS services use deployment circuit breakers.

deployment_circuit_breaker {
  enable   = true
  rollback = true
}

This allows ECS to detect unsuccessful deployments and automatically roll back.

Deployment health is also verified by GitHub Actions before the workflow completes.

Rollback

Because deployments use immutable Git SHA images, previous application versions remain identifiable.

Rollback can be performed by deploying an earlier known-good task definition or image SHA.

A rollback scenario was tested during development to verify service recovery.

Repository Structure
aws-devops-platform/
├── .github/
│   └── workflows/
│       ├── deploy.yml
│       ├── devsecops-security.yml
│       ├── terraform-apply.yml
│       └── terraform-ci.yml
│
├── app/
│   ├── app.py
│   ├── Dockerfile
│   └── requirements.txt
│
├── terraform/
│   ├── bootstrap/
│   ├── environments/
│   │   └── dev/
│   └── modules/
│       ├── ecr/
│       ├── ecs/
│       ├── github-oidc/
│       ├── iam/
│       ├── monitoring/
│       ├── network/
│       └── staging/
│
└── README.md
Running Terraform

Initialize:

cd terraform/environments/dev
terraform init

Validate:

terraform validate

Review the plan:

terraform plan

Infrastructure changes should normally be performed through the repository's controlled Terraform CI/CD workflow rather than applying directly from a developer workstation.

Security Scanning Locally
Gitleaks
gitleaks detect --source . --redact
Semgrep
semgrep scan --config auto app
Checkov
checkov -d terraform --framework terraform
Trivy
trivy fs --scanners vuln,secret .

Terraform configuration:

trivy config terraform
Key Engineering Lessons

This project demonstrates several production-oriented DevOps principles:

Build an artifact once and promote the same artifact between environments.
Avoid long-lived cloud credentials by using workload identity/OIDC.
Keep infrastructure changes reviewable through Terraform plans.
Protect production deployments with approval gates.
Use immutable container images for traceability and rollback.
Integrate security throughout CI/CD rather than treating it as a final step.
Apply least privilege to CI/CD identities.
Distinguish real security risk from scanner noise and architectural exceptions.
Use monitoring and automated rollback as part of deployment engineering.
Protect infrastructure state and control who can modify production resources.
Future Enhancements

Potential production enhancements include:

HTTPS with AWS Certificate Manager
HTTP-to-HTTPS redirects
AWS WAF
Private ECS networking with NAT Gateway or VPC endpoints
VPC Flow Logs
Customer-managed KMS keys
ALB access logging
Extended CloudWatch log retention
Centralized security reporting
SBOM generation and artifact signing
Policy-as-Code enforcement
Author

Lawal Oladele Sulaiman

DevOps & Cloud Engineering

AWS • GCP • Terraform • Docker • Kubernetes • GitHub Actions • Jenkins • Ansible • GitOps • DevSecOps
