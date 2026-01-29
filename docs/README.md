# NAS Financial AWS Cloud Migration (Terraform + Jenkins)

This repository contains an enterprise-style AWS cloud architecture project for **NAS Financial Group**, designed and implemented using **Terraform (Infrastructure as Code)** and a **Jenkins CI/CD pipeline**.

The goal is to migrate selected workloads from on-prem to AWS while meeting strict requirements around:
- IAM governance (multi-team access control)
- PCI (encrypted traffic)
- GDPR geo-access controls
- High availability + auto scaling
- Private intranet application
- Cross-account auditing (N2G Auditing)
- Monitoring + alerting
- Disaster recovery (cross-region backups)
- Secure storage for PII with lifecycle retention

---

## Phase 1 (Completed): Project Bootstrap & Terraform Foundation

This phase sets up the repository structure and Terraform baseline required for the rest of the project.

### ✅ What was implemented
- Repository skeleton created for a **real-life modular Terraform layout**
- Documentation structure prepared under `docs/`
- Terraform environment folder created under `envs/prod/`
- Terraform backend configured using:
  - **S3 remote state**
  - **DynamoDB state locking**
- AWS providers configured for:
  - NAS primary region (`us-east-1`)
  - NAS DR region (`us-west-2`) using a provider alias
  - N2G Auditing account (separate AWS account) using a provider alias

### ✅ Locked decisions (key project settings)
- **NAS Account ID:** `436083576844`
- **N2G Auditing Account ID:** `370445361290`
- **Primary Region:** `us-east-1`
- **DR Region:** `us-west-2`
- **Domain:** `anzyworld.com`
- **Route 53 Hosted Zone ID:** `Z06049403PYBB5K85PB4V`
- **Subdomains:**
  - Dynamic (US only): `app.anzyworld.com`
  - Static (non-US): `stop.anzyworld.com`
  - Jenkins: `jenkins.anzyworld.com`
- **Compute (Dynamic Website):** ECS (Fargate)
- **Database:** Amazon RDS
- **Intranet management:** AWS Systems Manager (SSM)
- **Geo routing (GDPR):** Route 53 Geo Location Routing

---

## Repository Structure
```bash
nas-financial-aws-cloud-migration-terraform-jenkins/
├── modules/ # Reusable Terraform modules (built per component)
│ ├── iam/
│ ├── network/
│ ├── storage/
│ ├── ecs_dynamic_site/
│ ├── ecs_intranet/
│ ├── rds/
│ ├── static_site/
│ ├── monitoring/
│ └── jenkins/
├── envs/
│ └── prod/ # Production environment (root Terraform execution directory)
│ ├── backend.tf
│ ├── providers.tf
│ ├── versions.tf
│ ├── main.tf
│ ├── variables.tf
│ └── outputs.tf
└── docs/
├── decisions.md # Architecture contract / design decisions
├── project-roadmap.md # Phased roadmap for implementation
└── architecture.md # (To be completed) architecture details/diagram
```
---


---

## Terraform Backend (Remote State)

Terraform state is stored remotely in an S3 bucket with DynamoDB locking to prevent state corruption during concurrent operations.

### Backend resources created (NAS account)
- **S3 bucket** for Terraform state (remote backend)
- **DynamoDB table** for Terraform state locking

> These resources are required before running `terraform init`.

---

## AWS CLI Profiles Required

This project uses AWS CLI profiles (best practice) to separate access between accounts.

Expected profiles:
- `nas-prod`  → NAS account (`436083576844`)
- `n2g-audit` → N2G Auditing account (`370445361290`)

Verify profiles:
```bash
aws sts get-caller-identity --profile nas-prod
aws sts get-caller-identity --profile n2g-audit
```
---

## Running Terraform (Phase 1 Validation)

All Terraform commands should be run from:
```bash
cd envs/prod
```
- Validate the setup:
```bash
terraform init
terraform validate
```
<img width="1920" height="978" alt="Screenshot (1306)" src="https://github.com/user-attachments/assets/8afb2ed1-c6de-47e7-94bb-facfb819f48e" />
<img width="1920" height="986" alt="Screenshot (1307)" src="https://github.com/user-attachments/assets/e75614be-a6c7-4415-8cb0-923fd5734d3f" />

---
## Next Phase: IAM & Governance (Phase 2)

Next we will implement IAM roles and policies for:

CloudSpace Engineers: Admin access with explicit billing deny

NAS Security Team: Full admin access including billing

NAS Operations Team: Admin access restricted to us-east-1 only

N2G Auditing: Cross-account role assumption + least privilege

Well-Architected Tool access for auditors only (no other console permissions)

### Step 1 Create IAM module structure
- inside:
```bash
modules/iam/
```
- i add:
```bash
modules/iam/
├── roles.tf
├── policies.tf
├── trust.tf
├── outputs.tf
└── variables.tf
```
#### modules/iam Overview:
File Overview

**variables.tf**
Declares input variables used by the IAM module, including project naming, AWS account IDs, and trusted principals for role assumption.

**roles.tf**
Creates IAM roles for internal teams and external auditors:

CloudSpace Engineers (admin access without billing)

NAS Security Team (full admin access with billing)

NAS Operations Team (admin access restricted to us-east-1)

N2G Auditing (cross-account auditing role)

**policies.tf**
Defines custom IAM policies used to enforce security constraints, such as:

Explicit denial of billing access

Region-based access restrictions

Minimal read-only permissions for external auditors

**trust.tf**
Defines trust relationships (assume role policies) that control who can assume each role, including cross-account trust for the N2G Auditing AWS account.

**outputs.tf**
Exposes the ARNs of all IAM roles created by the module, allowing them to be referenced by other Terraform modules and for testing role assumption.

### Step 2 — Start with the simplest role

We always begin with:
👉 CloudSpace Engineers role

Why?

- No region restrictions yet

- No cross-account logic

- Lets you learn the pattern
- AFTER populating the modules/iam/ files, Call the IAM module from envs/prod/main.tf and imput the contain of envs/prod/outputs.tf.
-  `Run` the following comands from `env/prod`
```bash
terraform fmt -recursive
terraform validate
terraform plan

