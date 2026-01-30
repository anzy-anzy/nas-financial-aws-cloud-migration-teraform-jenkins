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

Next i will implement IAM roles and policies for:

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
terrafor init # for the second time 
terraform fmt -recursive
terraform validate
terraform plan
``` 

<img width="1920" height="978" alt="Screenshot (1310)" src="https://github.com/user-attachments/assets/997dbdf0-5f78-4d7b-aee4-8abbb5faecb0" />
<img width="1920" height="982" alt="Screenshot (1311)" src="https://github.com/user-attachments/assets/d71696fc-9f1a-4a0e-8ce0-474b5a99dc7e" />

```bash
terraform apply
```
<img width="1920" height="988" alt="Screenshot (1312)" src="https://github.com/user-attachments/assets/b6ff6cc8-ef09-42c8-8790-64f9d0cf8936" />
#### After terraform apply, AWS will have:
🔐 IAM Roles (4)

1) **CloudSpace Engineers Role**

Admin access

❌ Billing explicitly denied

2) **NAS Security Team Role**

Full admin access

✅ Billing included

2) **NAS Operations Team Role**

Admin access

🚫 Restricted to us-east-1 only

4) **N2G Auditing Role**

Lives in NAS account

Can be assumed from N2G account

Minimal read-only audit permissions (for now)

#### IAM Policies (3 custom)

Deny Billing Policy

Deny Non–us-east-1 Policy

N2G Minimal Read-Only Policy

#### Policy Attachments

Policies attached to the correct roles

AWS-managed AdministratorAccess attached where appropriate

#### Terraform Outputs

**After apply**, Terraform will output:

Role `ARNs` for all 4 roles

These ARNs are important for:

Testing sts:**AssumeRole**

Later wiring `Jenkins`, `ECS tasks`, and `auditors`

<img width="1920" height="990" alt="Screenshot (1313)" src="https://github.com/user-attachments/assets/d9ddb5ec-6bdd-40a0-b20a-fd92e1f6b6a2" />

#### ✅ IAM Role Validation & Security Testing
Region Restriction Enforcement Test (NAS Operations Team)

To validate that IAM policies are correctly enforcing region-based **access control**, a manual sanity test was performed using AWS STS role assumption.

**Test Objective**

Verify that the `NAS Operations Team role`:

✅ Can perform actions in the allowed **region** (us-east-1)

❌ Is explicitly denied **actions** in any other region

**Test Method**

Assumed the NASOperationsTeamRole using AWS STS:
```bash
aws sts assume-role \
  --role-arn arn:aws:iam::<NAS_ACCOUNT_ID>:role/nas-financial-prod-NASOperationsTeamRole \
  --role-session-name ops-test
```
<img width="1920" height="974" alt="Screenshot (1314)" src="https://github.com/user-attachments/assets/c88090e4-9a4c-4340-b20c-97151b1daa53" />
**Exported** the temporary credentials returned by STS.
```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=...
```
<img width="1920" height="998" alt="Screenshot (1316)" src="https://github.com/user-attachments/assets/a3f87374-8523-4014-98fd-f55ddd91f22d" />

**Check** IF the NAS account terminal is in the operation team with the role that has **Admin access** and **Restricted to us-east-1 only**
<img width="1920" height="980" alt="Screenshot (1318)" src="https://github.com/user-attachments/assets/5f210a1b-7f1d-4855-bcbc-89b7c5d0c391" />
So am done testing i can now **reset my terminal**
```bash
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
```
## Phase 3 — Networking (VPC)
What i will be building in Phase 3
1) **VPC**

- Single VPC in us-east-1

- Proper CIDR planning

 2) **Subnets** (Multi-AZ)

- Public subnets (2 AZs):

- Public ALB (dynamic site)

- Jenkins ALB

- NAT Gateway

**Private subnets** (2 AZs):

- ECS (dynamic app)

- ECS / EC2 (intranet)

- RDS

3) **Internet Access**

- Internet Gateway (IGW)

- NAT Gateway (for private outbound access)

4) **Routing**

Public route table → IGW

Private route table → NAT Gateway

5) **Baseline Security Groups**

ALB security group

App security group

DB security group (locked to app only)
####  Step 1 — Prepare the network module
- populate the :
modules/network/
├── vpc.tf
├── subnets.tf
├── routes.tf
├── security_groups.tf
├── variables.tf
└── outputs.tf
#### Step 2 — Call the module from envs/prod/main.tf
```bash
module "network" {
  source = "../../modules/network"
```
#### step 3 Run the commands (from envs/prod)

Because you added a new module:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```
<img width="1920" height="963" alt="Screenshot (1319)" src="https://github.com/user-attachments/assets/3c97d8df-5899-40cb-92fe-774bb312a039" />
<img width="1920" height="978" alt="Screenshot (1320)" src="https://github.com/user-attachments/assets/10b9ef7e-3b7e-4c16-b285-d18a3c9cdaa5" />

