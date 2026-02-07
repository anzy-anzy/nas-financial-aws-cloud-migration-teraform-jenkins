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
├── modules/ 
│ ├── iam/  variables.tf outputs.tf policies.tf roles.tf trust.tf 
│ ├── network/ empty
│ ├── storage/
│ ├── budget/ main.tf variables.tf outputs.tf
│ ├── ecs_dynamic_site/ variables.tf outputs.tf alb.tf ecs.tf iam.tf route53.tf service.tf task.tf tls.tf 
│ ├── intranet_app/ main.tf variables.tf outputs.tf
│ ├── rds/ variables.tf outputs.tf alarms.tf backups.tf rds.tf secrets.tf subnet_group.tf versions.tf
│ ├── static_site/ main.tf variables.tf outputs.tf versions.tf
│ ├── grafana/ main.tf variables.tf outputs.tf
│ ├── vpc_flow_logs/ main.tf variables.tf outputs.tf
│ ├── auditing/ main.tf variables.tf outputs.tf alarms.tf cloudwatch.tf
│ ├── monitoring/ emty
│ └── jenkins/ main.tf variables.tf outputs.tf
├── Jenkinsfiles
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
 populate the :
 ```bash
modules/network/
├── vpc.tf
├── subnets.tf
├── routes.tf
├── security_groups.tf
├── variables.tf
└── outputs.tf
```

##### sumary contents for the modules/network/ files

**variables.tf**

Defines the inputs the network module needs:

Project/env naming (project, env)

VPC CIDR block (10.0.0.0/16)

Two Availability Zones list (azs)

Common tags map (tags)

**vpc.tf**

Creates the core networking boundary:

VPC with DNS support + hostnames enabled (needed for ALB/ECS/service discovery)

Internet Gateway (IGW) attached to the VPC (public internet access for public subnets)

**subnets.tf**

Creates subnets across 2 AZs:

2 `Public subnets`

Auto-assign public IPs enabled

Intended for ALBs + NAT Gateway

2 `Private subnets`

No public IPs

Intended for ECS tasks, intranet, and RDS

CIDRs are derived automatically from the VPC CIDR using cidrsubnet().

**routes.tf**
- Creates outbound/internet routing and NAT:
- Elastic IP for the NAT Gateway
1 `NAT Gateway` placed in the first public subnet (cost-optimized)
- Public route table:
-Default route 0.0.0.0/0 → IGW
-Associated to both public subnets
-Private route table:
-Default route 0.0.0.0/0 → NAT Gateway
-Associated to both private subnets
`This enables`:
- `Public subnets`: inbound/outbound internet
- `Private subnets`: outbound-only internet (updates, package installs)

**security_groups.tf`**
- Creates baseline security groups (SGs) for later phases:
- Public ALB SG
- Allows inbound 443 from internet (and 80 optionally for redirect)
- Allows all outbound
- Dynamic App SG (ECS Tasks)
- Allows inbound HTTP 80 ONLY from the public ALB SG
- Allows all outbound

**DB SG (RDS)**
- Allows inbound MySQL 3306 ONLY from the App SG
- Allows all outbound (normal for managed RDS)
- Internal ALB SG (Intranet)
- Allows inbound HTTP 80 ONLY from within the VPC CIDR
- Allows all outbound

**outputs.tf**
- Exports key IDs so other modules can plug in easily:
- vpc_id
- public_subnet_ids
- private_subnet_ids
- Security group IDs (public ALB, app, DB, internal ALB)
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
<img width="1920" height="978" alt="Screenshot (1320)" src="https://github.com/user-attachments/assets/8cf28f36-00ee-45bf-8897-9b2d0a78b126" />
**terraform apply**
<img width="1920" height="949" alt="Screenshot (1322)" src="https://github.com/user-attachments/assets/6466288c-6d7c-4bea-87d8-097a8683e362" />

**After apply** (fast verification checklist)

**In AWS Console**, confirm:
- VPC exists
- 2 public + 2 private subnets
- IGW attached to VPC
- NAT Gateway is Available
- Route tables:
- Public → IGW
- Private → NAT
 <img width="1920" height="994" alt="Screenshot (1324)" src="https://github.com/user-attachments/assets/fb39b55f-69c4-4fee-b131-7940d30224d8" />
  `Security geoups`
 - sg-alb-public
- sg-app-dynamic
- sg-db
- sg-alb-internal

<img width="1920" height="981" alt="Screenshot (1325)" src="https://github.com/user-attachments/assets/e0fcd725-7376-496c-85dc-20dd7bfdb381" />
  Elastic IP
<img width="1920" height="977" alt="Screenshot (1326)" src="https://github.com/user-attachments/assets/4cfc2eda-6a6c-444b-b652-ed5acf46e9b5" />

## Phase 4: ECS Dynamic Website (US Only)

- Now we build the dynamic site backbone:

 **What Phase 4 will create**
- ECS Cluster (Fargate)
- ECS Task Definition (sample web app)
-  ECS Service running across private subnets
-  Public ALB in public subnets
-  Target Group + Listener (HTTP now, HTTPS in next step)
-  CloudWatch log group for containers

Note: I’ll do HTTPS (ACM cert) as the next sub-step once ALB is working, because ACM + DNS validation is smoother when the ALB exists.

- Populate the files that would deliver the above resources.
```bash
modules/ecs_dynamic_site/
├── variables.tf        # Input variables for the ECS dynamic website (VPC, subnets, security groups, app sizing)
├── ecs.tf              # ECS cluster creation and CloudWatch log group for the dynamic application
├── iam.tf              # IAM task execution role for ECS (pull images, write logs to CloudWatch)
├── alb.tf              # Public Application Load Balancer, target group, and HTTP listener
├── task.tf             # ECS Fargate task definition using nginxdemos/hello container
├── service.tf          # ECS service running tasks in private subnets and attached to the ALB
└── outputs.tf          # Exports ALB DNS name, target group ARN, and ECS cluster name
```
 **OR**
 - `variables.tf` → “Configuration surface”
- `ecs.tf` → “Compute orchestration”
- `iam.tf` → “Service-level security”
- `alb.tf` → “Traffic ingress & health checks”
`task.tf` → “Application runtime definition”
`service.tf` → “High availability & scaling”
`outputs.tf` → “Inter-module integration”
This structure is exactly how production Terraform repos are organized.
#### Run commands (from envs/prod)
- Because you added a new module:
```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```
<img width="1920" height="973" alt="Screenshot (1328)" src="https://github.com/user-attachments/assets/f5851434-2d16-470c-ad77-4a8be2e9e109" />
<img width="1920" height="966" alt="Screenshot (1329)" src="https://github.com/user-attachments/assets/2a0a0cd5-ecb3-46f1-9400-08ba79f2eb3e" />
**terraform apply**
<img width="1920" height="955" alt="Screenshot (1330)" src="https://github.com/user-attachments/assets/2e25be80-d585-43b4-ba9a-90c200fe5aa1" />
- Get the `dynamic_alb_dns_name`
```bash
terraform output dynamic_alb_dns_name
```
- check it on the website
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/efd44410-bd58-49cc-8a5e-c57b8abe36f1" />
**console checks:**
- `ECS service` → 2 RUNNING tasks
-`Load Balancer` `Target group` → healthy
- CloudWatch logs` → streaming
<img width="1920" height="970" alt="Screenshot (1332)" src="https://github.com/user-attachments/assets/a2dee705-35af-45d7-81de-d9de86ff2096" />
<img width="1920" height="980" alt="Screenshot (1333)" src="https://github.com/user-attachments/assets/90e1346c-fa79-43b0-87e4-f9f1330e3ad1" />
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/765ff83d-e2c7-4a97-8db8-a99f6102b934" />
<img width="1920" height="834" alt="Screenshot (1334)" src="https://github.com/user-attachments/assets/6e428873-d6b3-4980-a88f-384c9d36cf47" />

## Phase 4.1: PCI/GDPR foundation
- Next i should secure and name the dynamic app properly:
- **implement**:
- `ACM certificate` for app.anzyworld.com
- HTTPS listener (443) on the ALB
- Redirect HTTP (80) → HTTPS (443)
- Route 53 alias record:
- app.anzyworld.com → ALB
**This is key for PCI compliance (encrypted traffic)**.

#### Sumary for the changes we will make to achieve 

```bash
Users → Route 53 (app.anzyworld.com)
      → ALB (HTTP:80 redirects → HTTPS:443)
      → ALB (HTTPS:443) → ECS (private subnets)
```

`modules/ecs_dynamic_site/variables.tf`

 Added variables needed for TLS + DNS:
 
- `route53_zone_id` (Hosted Zone ID)
- `dynamic_fqdn` (app.anzyworld.com)
- `ssl_policy` (TLS security policy)

`modules/ecs_dynamic_site/tls.tf (new file)`

Creates and validates the ACM certificate:

- Requests cert for app.anzyworld.com
- Generates Route 53 validation records automatically
- Completes certificate validation (becomes “Issued”)

`modules/ecs_dynamic_site/route53.tf (new file)`

Creates Route 53 DNS record:

`app.anzyworld.com` becomes an **Alias A** record pointing to the ALB 

-`modules/ecs_dynamic_site/alb.tf`

`Modified listener behavior:`

- Old: HTTP :80 → forward to target group
- New:
 - HTTP :80 → redirect to HTTPS :443
 - HTTPS :443 → forward to target group

✅ Enforces encrypted traffic (PCI)

`modules/ecs_dynamic_site/service.tf`

Updated dependency:

-Service now depends on HTTPS listener, so Terraform creates things in the correct order.

`envs/prod/main.tf`
-` Updated ECS` module call to pass:
- `route53_zone_id` = var.route53_zone_id
- `dynamic_fqdn` = var.dynamic_fqdn

So the module can create the certificate + DNS.
#### Commands to run now (from envs/prod)
```bash
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```
<img width="1920" height="998" alt="Screenshot (1338)" src="https://github.com/user-attachments/assets/27f41b85-1537-438a-9ed5-7f0ddf8f016c" />

**What this plan will do**

`Plan: 5 to add, 1 to change, 0 to destroy. ✅ Safe.`

```bash
Create an ACM certificate for app.anzyworld.com
Create the Route 53 DNS validation record for the certificate
Create the Route 53 alias record app.anzyworld.com → your ALB
Create the HTTPS listener on the ALB (port 443) using the certificate
Create the ACM certificate validation resource
Update in-place your existing HTTP listener (port 80) to redirect to HTTPS
```
`That’s exactly the PCI step`.

- Apply now
<img width="1920" height="981" alt="Screenshot (1339)" src="https://github.com/user-attachments/assets/9629d6a2-4d3e-4e49-b20a-e467bed7e030" />

**After apply, test:**

- http://app.anzyworld.com → should redirect to HTTPS

- https://app.anzyworld.com → should load the nginx demo page

<img width="1920" height="1013" alt="Screenshot (1340)" src="https://github.com/user-attachments/assets/c316e648-09a9-4f22-bbae-4e032f35a97d" />

## Phase 5 — Database (RDS) + Secrets Manager + BackupsDatabase (RDS)

**Engine: MySQL**
- Instance: `db.t3.micro` (project-friendly, still realistic)
- High Availability: `Multi-AZ` = YES ✅
- `Backups: Enabled` (automated)
- DR: Snapshot copy to secondary region (us-west-2)
**Secrets**
- AWS `Secrets Manager` for DB credentials (no plaintext in Terraform) ✅
- Auto-generated strong password
**Monitoring & Alerts**
- CloudWatch `Alarms` (ALB 5xx, ECS task health, RDS health)
- SNS Topic for alerts
- Notification email: `anselmebsiy58@gmail.com`
I'll receive a `confirmation email` from AWS — you must click Confirm subscription once it arrives.
**Security**
- RDS in private subnets only
- DB SG allows only from app SG
- No public DB access
- IAM least privilege maintained
#### Files i will add
```bash
modules/rds/
├── variables.tf        # DB inputs (engine, size, AZs, tags)
├── secrets.tf          # Secrets Manager (credentials)
├── subnet_group.tf     # Private subnet group
├── rds.tf              # RDS instance (Multi-AZ)
├── backups.tf          # Snapshot & cross-region copy
├── alarms.tf           # CloudWatch alarms
└── outputs.tf          # Endpoint, secret ARN
Wire the module into envs/prod/main.tf
```
#### Run commands
- From `envs/prod`

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```
<img width="1920" height="986" alt="Screenshot (1341)" src="https://github.com/user-attachments/assets/b4150e1b-139e-4ede-aab7-fbbfbbd8f3c0" />
#### What this plan is about to do (clean summary)
**Network**
- 1 `in-place update`
 - NAT Gateway gets a regional_nat_gateway_address
 - This is harmless and expected (provider version upgrade side effect)
 **RDS (Core of Phase 5)**
- Terraform will create:
**Databas**
 - MySQL RDS
 - db.t3.micro (project-friendly)
 - Multi-AZ = true 
 - Private (not publicly accessible) 
 - Encrypted at rest (KMS-managed) 
 - Security Group locked to app tier only 

**Credentials**
 - Random password generated
 - Stored securely in AWS Secrets Manager
- No plaintext password in Terraform state or code

**Backup & Disaster Recovery (Very strong design)**
- AWS Backup Vault (Primary – us-east-1)
- AWS Backup Vault (DR – us-west-2)
- Daily backups
- Lifecycle rules:
- Hot retention (~30–35 days)
- Archive up to 5 years (1825 days) ✅
- Cross-region copy enabled (meets DR requirement)
`This perfectly matches the project brief`.

**Monitoring & Alerts**
- `CloudWatch` alarms:
- High CPU
- Low free storage
- SNS Topic created
- Email subscription:
⚠️ i will receive a confirmation email after apply
and i will  click “Confirm subscription”, otherwise alerts won’t deliver.

**Outputs (important for next phases)**
 **Terraform will expose:**
- rds_endpoint → used by ECS app later
- rds_secret_arn → used by ECS task role
- alerts_topic_arn → reusable for other alarms
- These outputs are exactly what we need next.
- About the provider warning (final word)

  ```bash
  terraform apply
  ```
<img width="1920" height="990" alt="Screenshot (1345)" src="https://github.com/user-attachments/assets/d3abf347-a11b-4087-8808-42a4776759c5" />

  #### Post-Apply Verification Checklist
1) Confirm SNS email subscription (MOST IMPORTANT)

- Checked my inbox for an AWS email like “AWS Notification - Subscription Confirmation”. and confirm it.
<img width="1920" height="998" alt="Screenshot (1344)" src="https://github.com/user-attachments/assets/5174e7e8-c539-4050-9fe1-9ef20556366c" />
2) Terraform outputs (copy these)

- From envs/prod run:
```bash
terraform output
```
3) RDS Console checks (primary region us-east-1
```bash
Status: Available
Multi-AZ: Yes
Publicly accessible: No
Storage encrypted: Yes
VPC security group: should be your ...sg-db
```
<img width="1920" height="990" alt="Screenshot (1345)" src="https://github.com/user-attachments/assets/3f796ae7-d90b-42cd-9286-554adc9bd5a1" />

4) Secrets Manager checks
5) AWS Backup checks (this proves DR requirement)

**In us-east-1**
**Console → AWS Backup**
- Backup vault exists: nas-financial-prod-backup-vault-primary
- Backup plan exists: nas-financial-prod-backup-plan
- Resource assignment includes your RDS instance
 
**In us-west-2**
**Switch region to us-west-2:**
- Vault exists: nas-financial-prod-backup-vault-dr
- (First actual recovery point may show up after the first scheduled run.)
<img width="1920" height="954" alt="Screenshot (1347)" src="https://github.com/user-attachments/assets/8e82bda4-fa97-448a-b788-89bd882b443a" />
<img width="1920" height="960" alt="Screenshot (1348)" src="https://github.com/user-attachments/assets/f5e58b62-d577-416f-98ab-01690eb313af" />

**Quick CLI verification** (optional but strong)
- Check DB is NOT public
- Check Multi-AZ
<img width="1920" height="999" alt="Screenshot (1349)" src="https://github.com/user-attachments/assets/739266b3-78ef-409e-ae6d-99e7621b9fb4" />

## Phase 6A – Secure ECS ↔ RDS Integration (Secrets & IAM)
- In this phase, the dynamic ECS application is securely prepared to connect to the private RDS database without exposing credentials or opening network access.
**What was implemented**
  
##### Dedicated ECS Task IAM Role
- Created a task role separate from the execution role.
- Follows least-privilege principles.
- Used only by the running application containers.
- 
**Secrets Manager Integration**
- Database credentials are stored in AWS Secrets Manager.
- ECS tasks are granted permission to read only the specific RDS secret.
- No database credentials are hardcoded in Terraform, GitHub, or ECS task definitions.
- 
**Secure Secret Injection**
- Database username and password are injected into the container at runtime using ECS secrets.
- Credentials never appear in plaintext in logs or configuration files.
- 
**Database Connection Metadata**
- RDS endpoint and database name are injected as environment variables.
- The application can connect to the database without needing public access.
- 
**No Public Exposure**
- RDS remains in private subnets.
- No inbound internet access to the database.
- Only ECS tasks within the VPC can reach the database.
- 
**Why this matters**
- Meets security best practices for cloud-native applications.
- Aligns with PCI and compliance requirements by preventing credential exposure.
- Enables future application upgrades without infrastructure redesign.
- Provides a clean foundation for adding real database-backed applications.

**Current State**
- The application container does not yet use the database.
- This phase focuses on secure plumbing and access control.
- A future phase will replace the demo container with a real application that actively connects to MySQL.

##### Phase 6A – Secure ECS to RDS Wiring
- In this phase, the ECS service was securely prepared to access the private RDS database without exposing credentials.
**What changed**
-Added a dedicated ECS task IAM role (separate from the execution role).
- Granted the task role least-privilege access to read the RDS credentials from AWS Secrets Manager.
- Injected database credentials into the container at runtime using ECS secrets.
- Passed the RDS endpoint and database name as environment variables.
- Wired ECS and RDS modules together in the production environment.
- 
**Result**
- Database credentials are never stored in code or Terraform state.
- RDS remains private and accessible only from ECS tasks.
- The infrastructure is ready for a real database-backed application in the next phase.

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```
<img width="1920" height="989" alt="Screenshot (1350)" src="https://github.com/user-attachments/assets/4b2374e6-4035-4dd8-8fe6-9b6a335e09ba" />

```
terraform apply
```
<img width="1920" height="970" alt="Screenshot (1351)" src="https://github.com/user-attachments/assets/044f3569-b1ed-472b-bcf3-2b71e069cc4d" />

### Phase 6A Post-Apply Checklist
1) ECS Service health (must still be stable)
- `Check`:

- Desired tasks = 2
- Running tasks = 2
- No constant “stopping/starting” in Events
 
2) Task Definition has the new role + secrets
- Task role ARN is set (not empty)

<img width="1920" height="953" alt="Screenshot (1356)" src="https://github.com/user-attachments/assets/904f193d-7eaa-4a10-8d2d-9c8c91786705" />

**Under container dynamic-app**:
- Environment variables:
- DB_HOST
-DB_NAME

**Secrets**:
- DB_USER
- DB_PASSWORD
- This proves the wiring is in place.

3) Secrets Manager permission is correct (IAM)
- Confirm it has an attached policy allowing:
```bash
secretsmanager:GetSecretValue
secretsmanager:DescribeSecret
Resource = your exact secret ARN
...:secret:nas-financial/prod/rds/mysql/credentials-...
```
**Least privilege**.

<img width="1920" height="966" alt="Screenshot (1354)" src="https://github.com/user-attachments/assets/acb98804-c7e4-4cb7-9f5b-c488260122de" />

4) CloudWatch logs (look for secret injection errors)
- Console → CloudWatch → Log groups → /ecs/nas-financial-prod-dynamic → newest stream
###### We’re checking for errors like:
- AccessDenied to Secrets Manager
- “Unable to fetch secret”
- Task failing to start
Even though nginx doesn’t use DB, ECS still must successfully inject secrets.

5) Website still works
**Open**:

`https://app.anzyworld.com`

Should still show the nginx demo page

---

## Phase 7A Plan (What we will create)
A) Static site (`stop.anzyworld.com`)

**I will create**:
- S3 bucket (private)
- CloudFront distribution (HTTPS)
- ACM certificate for stop.anzyworld.com (must be in us-east-1)
- Route 53 alias record: stop.anzyworld.com → CloudFront
- Upload a simple index.html that shows the GDPR message

B) Geo-routing entrypoint (`nas.anzyworld.com`)
- We will create:
- Route 53 record for www.anzyworld.com
- Geolocation: US → ALB (dynamic)
Default → CloudFront (static)

**the following modules be created**
```bash
modules/static_site/
├── main.tf
├── variables.tf
└── outputs.tf
```
##### Updated / Added for Phase 7A (Static + Geo Routing)
`envs/prod/providers.tf`
- Added aws.`us_east_1` alias for ACM certs used by CloudFront.

`modules/static_site/*` (new module)
- Creates an S3 private bucket with an “Access Restricted” HTML page.
- Creates CloudFront with OAC (secure S3 access).
- Creates ACM cert for stop.anzyworld.com and validates via Route 53.
- Creates Route 53 record for stop.anzyworld.com → CloudFront.

`envs/prod/main.tf` (will be updated)
- Adds the static_site module.
- Adds Route 53 Geolocation routing for `nas.anzyworld.com`:
  -US → Dynamic ALB (ECS)
 - Default (non-US) → Static CloudFront

`modules/ecs_dynamic_site/outputs.tf` (only if missing)
- Exposes ALB dns_name + zone_id so Route 53 geolocation alias can point to it.
#### Run commands from envs/prod
```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```
<img width="1920" height="986" alt="Screenshot (1358)" src="https://github.com/user-attachments/assets/004d8ad4-547a-435b-b3cf-3d527129e52c" />
```bash
terraform apply
```
-**Got mix up here and alot of troubleshooting here but all good now**
so i now have `nas.anzyworld.com` that would onlu deliver it content to those to the US and shows "  Restricted Access" to anyone else.

<img width="1920" height="997" alt="Screenshot (1364)" src="https://github.com/user-attachments/assets/0aa53c46-7973-49ea-b700-21950e922d0b" />
## Phase 7B goal
- Build a dynamic internal application that is not publicly accessible
- Server can still download packages from the internet (NAT gateway)
- Employees access it through HTTP (internal only)
- Management access only via SSM Session Manager (no SSH)
- 
  **Phase 7 deliverables** (what i’ll create)
- Internal ALB (private) OR no ALB + direct internal access (we’ll choose the cleanest)
- ECS service or EC2 for intranet (we’ll use the simplest solid option)
- `Security groups locked to`:
- Only allow HTTP from internal sources (VPC or corporate CIDR)
- SSM permissions for CloudSpace engineers
- No public IPs, no inbound from the internet
#### What changes in Terraform at this stage
- create a new module, not touch the public site.

**New module**

```bash
modules/
└── ecs_intranet/
    ├── alb.tf          # Internal ALB (no public IPs)
    ├── ecs.tf          # ECS cluster/service (or reuse cluster)
    ├── task.tf         # Task definition (simple demo app)
    ├── iam.tf          # ECS task roles
    ├── security.tf     # Strict SG rules
    ├── variables.tf
    ├── outputs.tf
```
```bash
terraform fmt -recursive
terraform validate
terraform plan
```

**Terraform Plan sumary**
- Security Group (HTTP only from `10.0.0.0/16`)
- IAM Role for EC2 to use SSM (`AmazonSSMManagedInstanceCore`)
- IAM Instance Profile
- Private EC2 Instance in private subnet (`no public IP`)
- Route53 Record `intranet.anzyworld.com` (private/internal style access)
- Supporting attachments/policies

```bash
terraform apply
```
<img width="1920" height="990" alt="Screenshot (1366)" src="https://github.com/user-attachments/assets/f9b82cb1-d1d9-4def-849f-daa317b05a8a" />

**What Terraform applied (terraform apply)**
- Terraform actually created the intranet stack and installed Apache using user_data:
-  SSM agent is running
- IAM permissions are correct
- instance can reach SSM endpoints (via NAT/VPC routing)
  - Open a new terminal **Powershell** and install `session manager`
```bash
curl https://s3.amazonaws.com/session-manager-downloads/plugin/latest/windows/SessionManagerPluginSetup.exe
dir .\SessionManagerPluginSetup.exe # if it dosen't work,i:
Invoke-WebRequest `
-Uri "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/windows/SessionManagerPluginSetup.exe" `
-OutFile ".\SessionManagerPluginSetup.exe"
session-manager-plugin # it will show version
aws ssm start-session `
  --target i-0d74093b66aec5997 `
  --document-name AWS-StartPortForwardingSession `
  --parameters "portNumber=80,localPortNumber=8080" # starting your session
```
<img width="1920" height="974" alt="Screenshot (1368)" src="https://github.com/user-attachments/assets/003361fa-b2f3-47a4-bddc-72463e0339a8" />

- Open Browser
`http://localhost:8080`
<img width="1920" height="950" alt="Screenshot (1369)" src="https://github.com/user-attachments/assets/554ebc14-c204-4630-8069-1c6fe470a9eb" />
<img width="1920" height="991" alt="Screenshot (1371)" src="https://github.com/user-attachments/assets/8d146b5d-1fd5-484e-8b04-fce74fc4abd6" />

##### Finishing touches for phase 7 b
1) Create a private hosted zone for `anzyworld.com`
- It will create:
- `aws_route53_zone.private_anzyworld`
- Name: `anzyworld.com`
- Attached to your VPC: `vpc-0e370df2df452f1a7`

This means DNS records inside this zone only work for clients inside the VPC (VPN/Client VPN/Direct Connect/EC2/SSM port-forward use case).

2)  Move intranet.anzyworld.com into the Private Hosted Zone
- Terraform shows:
- `module.intranet_app.aws_route53_record.intranet must be replaced`

**That’s normal because**:

- The old record is currently in your public hosted zone (Z060494...)
- After this change, it will be recreated in the private zone (new zone_id)

So it will:

- destroy the public-zone intranet record
- create a private-zone intranet record
- That’s exactly what we want for an intranet.

<img width="1920" height="997" alt="Screenshot (1377)" src="https://github.com/user-attachments/assets/324fc940-bb9f-428f-8ed5-4c143bb5e77b" />
- `intranet.anzy.world Will no longer exist as a public but in the private hosted zone so its vpc scoped and do not resolve on the public internet
<img width="1920" height="616" alt="Screenshot (1378)" src="https://github.com/user-attachments/assets/4ee291d5-feea-4e08-9438-cd20d7b2a8a7" />

 ## Phase 8 = Auditing & Visibility.
 I’ll do this in a real-life order:

- `CloudTrail` (audit trail) → S3 (log archive)
- Optional but recommended: CloudTrail → CloudWatch Logs (near-real-time)
- Tighten S3 security (encryption + block public + retention)
- Quick verification commands (CLI)

**Below is the clean plan**.

#### Phase 8 Deliverables (what we’ll build)
A) CloudTrail (multi-region)
- Records who did what in AWS
- Includes global services (IAM, etc.)
B) Central log bucket (S3)
- Encrypted
- Block public access
-Retention/lifecycle rules
C) Quick verification
- Confirm trail is logging
- Confirm logs land in S3
#### Added these new files
```bash
modules/auditing/
  main.tf
  variables.tf
  outputs.tf
```
- call the module im envs/prod/main.tf
```
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```
<img width="1920" height="998" alt="Screenshot (1379)" src="https://github.com/user-attachments/assets/ff0e7f96-cb0f-4766-914b-4f9492f73954" />

#### After apply: what to check (commands)
1) Confirm CloudTrail exists
2) Confirm logging is ON
```bash
aws cloudtrail describe-trails --query "trailList[*].[Name,S3BucketName,IsMultiRegionTrail,IncludeGlobalServiceEvents]" --output table #Confirm CloudTrail exists
aws cloudtrail get-trail-status --name nas-financial-prod-trail    #Confirm logging is ON 
aws s3api get-public-access-block --bucket nas-financial-prod-cloudtrail-436083576844  #Confirm S3 bucket exists + is private
aws s3 ls s3://nas-financial-prod-cloudtrail-436083576844/AWSLogs/ --recursive --human-readable --summarize  #Confirm logs are arriving in S3
```
<img width="1920" height="974" alt="Screenshot (1380)" src="https://github.com/user-attachments/assets/3a221d47-949d-401a-87c8-f70e89e3933f" />
<img width="1920" height="993" alt="Screenshot (1382)" src="https://github.com/user-attachments/assets/4db8fb10-13b2-48b8-9d28-14e977f1232c" />

# Phase 8B — CloudTrail → CloudWatch + Security Alarms 

## Goal (What we’re building)
In Phase 8B we extend CloudTrail auditing by sending CloudTrail events to **CloudWatch Logs**, then create **metric filters + alarms** to detect security-critical activity and notify the team via **SNS**.

This gives us real-time security monitoring on top of the audit trail.

---

##  Phase 8B Adds
### 1) CloudTrail to CloudWatch Logs (near real-time)
- Attach CloudTrail to a CloudWatch Log Group:
  - Log Group name: `/aws/cloudtrail/<project>-<env>`
- Create IAM Role/Policy that allows CloudTrail to publish logs to CloudWatch

### 2) Detection (Metric Filters)
We create CloudWatch **Log Metric Filters** on the CloudTrail log group for:
- **Root activity**
  - Detects when the Root user is used
- **Security Group changes**
  - Detects SG rule changes and SG create/delete activity
- **CloudTrail tampering**
  - Detects StopLogging / DeleteTrail / UpdateTrail

Each filter writes a custom metric into a security namespace.

### 3) Alerting (CloudWatch Alarms + SNS)
- CloudWatch alarms are created for each metric filter
- Alarm actions send notifications to the **existing SNS topic**:
  - `nas-financial-prod-alerts` (from your Terraform outputs)

---

## Terraform Plan — What You Should See
When you run:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
```
<img width="1920" height="1002" alt="Screenshot (1386)" src="https://github.com/user-attachments/assets/dd4d936c-1516-47b9-8cbe-cdb498d841e0" />
#### terraform plan sumary
- update in-place for aws_cloudtrail.this
- Adding:
  - cloud_watch_logs_group_arn
  - cloud_watch_logs_role_arn
- + `create` CloudWatch log group for CloudTrail
- + `create` IAM role + inline policy for CloudTrail → CloudWatch
- + `create` metric filters (root, SG changes, CloudTrail changes)
- + `create` CloudWatch alarms linked to SNS
```bash
terraform apply
```
<img width="1920" height="1002" alt="Screenshot (1387)" src="https://github.com/user-attachments/assets/94dc9190-40a4-4827-8382-33f446d14489" />
`Terraform` will:
- `Create` the CloudWatch log group
- `Create` the IAM role/policy for CloudTrail log delivery
- `Update` the existing CloudTrail to deliver logs to CloudWatch
- `Create` metric filters
- `Create` alarms that notify SNS
###### Verification after apply
```bash
# Confirm CloudTrail is sending to CloudWatch Logs
aws cloudtrail describe-trails --query "trailList[?Name=='nas-financial-prod-trail'].[Name,CloudWatchLogsLogGroupArn,CloudWatchLogsRoleArn]" --output table
#Confirm log groups exist
aws logs describe-log-groups --log-group-name-prefix "/aws/cloudtrail/nas-financial-prod" --output table
#Confirm metric filters exist
aws logs describe-metric-filters --log-group-name "/aws/cloudtrail/nas-financial-prod" --output table
#Confirm alarms exist
aws cloudwatch describe-alarms --alarm-name-prefix "nas-financial-prod-ALARM" --output table
```
<img width="1920" height="982" alt="Screenshot (1388)" src="https://github.com/user-attachments/assets/e22c669e-cc72-4b4a-ad7b-5b92605b572b" />
 should see:
`nas-financial-prod-ALARM-RootActivity`
`nas-financial-prod-ALARM-SecurityGroupChanges`
`nas-financial-prod-ALARM-CloudTrailChanges`
## Phase 9A: Create Amazon Managed Grafana Workspace
**i'll will build**
- A Grafana workspace
- A service role for Grafana that allows reading from CloudWatch (and Logs if we enable it)
- Enable `data_sources = ["CLOUDWATCH"]` 

#### Create a new module:
- `modules/grafana/main.tf`
- `modules/grafana/variables.tf`
- `modules/grafana/outputs.tf`

**Then call it in**

`envs/prod/main.tf`
Run comands from envs/prod
```bash
terraform fmt -recursive
terraform validate
terraform plan
```
<img width="1920" height="1014" alt="Screenshot (1389)" src="https://github.com/user-attachments/assets/bae11aac-37e3-46e1-97c1-c87fb23e0c90" />
```bash
terraform apply
```
<img width="1920" height="973" alt="Screenshot (1391)" src="https://github.com/user-attachments/assets/738042b5-b31d-49cb-a897-8f8c69d5dbcc" />
<img width="1920" height="926" alt="Screenshot (1392)" src="https://github.com/user-attachments/assets/c1127020-8b44-41a8-8c7b-38236dd37a29" />
#### verifications after apply
```bash
aws grafana list-workspaces --region us-east-1 #Confirm the Grafana workspace exists
aws iam get-role --role-name nas-financial-prod-grafana-role #Confirm the IAM role exists (Grafana access role)
aws grafana describe-workspace --workspace-id <ID> --region us-east-1 # grafana URL
```
#### Phase 9A = Infrastructure readiness, not visualization work yet.
- Grafana workspace defined via Terraform
- IAM role created for Grafana
- Read access to CloudWatch + Logs
- Uses AWS SSO (best practice)
- Fully reproducible (IaC)

That’s exactly how it’s done in real life.

## Phase 9B  hardening + ops
- I’ll do two high-value, real-world things:
 - **VPC Flow Logs** → visibility for network/security investigations
 - **AWS Budget** + **alert email** → cost control (super important in real projects)
I’ll implement both in Terraform as new modules so we don’t break existing ones.
#### VPC Flow Logs
```bash
modules/vpc_flow_logs/main.tf
modules/vpc_flow_logs/variables.tf
modules/vpc_flow_logs/outputs.tf
```
##### budgets + Email Alerts
```bash
modules/budget/main.tf
modules/budget/variables.tf
modules/budget/outputs.tf
```
- Add both modules in `envs/prod/main.tf`
- Run the comands from `envs/prod`
```bash
terraform fmt -recursive
terraform validate
terraform plan
```
<img width="1920" height="977" alt="Screenshot (1393)" src="https://github.com/user-attachments/assets/7658fcec-844c-4bb3-affa-621eda140809" />
```bash
terraform apply
```
<img width="1920" height="960" alt="Screenshot (1394)" src="https://github.com/user-attachments/assets/1c283536-d1b8-4735-9c78-557b3a85e8a5" />
##### AFTER APPLY CHECK
- Verify `VPC Flow Logs` (core of this phase)
You should see:
- Flow log attached to vpc-0e370df2df452f1a7
- Destination: CloudWatch Logs
- Status: ACTIVE
- Traffic type: ALL
<img width="1920" height="923" alt="Screenshot (1396)" src="https://github.com/user-attachments/assets/e085afb8-5dad-4d98-b241-d4fe29df452e" />

- Verify `CloudWatch Log Grou`p for `Flow Logs`
<img width="1920" height="935" alt="Screenshot (1398)" src="https://github.com/user-attachments/assets/7e046df1-b702-4301-a708-7d289c99a708" />

- Verify IAM Role for Flow Logs
- Verify AWS Budget
<img width="1920" height="966" alt="Screenshot (1400)" src="https://github.com/user-attachments/assets/36fc1ee3-666e-4dd5-8c80-95efa0ee66e6" />
Budget name: `nas-financial-prod-monthly-budget`
Amount: `$30`
Alerts at `80%` and `100%`
Email: `anselmebsiy59@gmail.com`

At this point, THIS **environment has**:

✔ Network traffic visibility (VPC Flow Logs)
✔ Centralized logging (CloudWatch)
✔ Security audit trail (CloudTrail from Phase 8)
✔ Cost guardrails (AWS Budgets)
✔ Observability foundation (Grafana)

**This is exactly how production AWS accounts are run**.

# Phase 10 — Jenkins CI/CD for Terraform (NAS Financial Project)

#### Goal
Stand up a **private Jenkins server** inside the NAS AWS VPC and use it to run **Terraform plan/apply** from a controlled, auditable place (instead of your laptop).

This phase turns your repo into **Infrastructure-as-Code + Pipeline-as-Code**.

---

## What we built (Terraform)
Terraform creates a Jenkins host that is:
- **Private** (no public IP)
- Managed via **SSM Session Manager** (no SSH needed)
- Jenkins runs on **port 8080**
- Access Jenkins UI using **SSM port-forwarding** to `http://localhost:8080`

### Resources created by `module.jenkins`
- `aws_instance.jenkins` (t3.micro, private subnet)
- `aws_security_group.jenkins` (no inbound needed if you only use SSM)
- `aws_iam_role.jenkins_ssm` + `AmazonSSMManagedInstanceCore`
- `aws_iam_instance_profile.jenkins`

> ✅ You do NOT need to input your home IP anywhere because we are NOT exposing Jenkins publicly.

---

## Repo location (assumed)
Your repo: `nas-financial-aws-cloud-migration-teraform-jenkins`

Terraform environment:
- `envs/prod/`

---

## Terraform steps (i already already did)
From `envs/prod`:

```bash
terraform fmt -recursive
terraform init
terraform plan
terraform apply
```
<img width="1920" height="960" alt="Screenshot (1402)" src="https://github.com/user-attachments/assets/d52237f2-b377-4bed-b70b-6f461a70c262" />


Expected: Jenkins EC2 is created successfully.

#### Verification checklist (Phase 10)
1) Confirm instance exists
<img width="1920" height="990" alt="Screenshot (1406)" src="https://github.com/user-attachments/assets/d0f9e520-d0bd-4a22-959a-44fab2ecc249" />
2) Start port-forwarding session (keep this terminal OPEN)
```bash
aws ssm start-session \
  --target <JENKINS_INSTANCE_ID> \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["8080"],"localPortNumber":["8080"]}' \
  --region us-east-1
```
- Open `http://localhost:8080`

- Get initial Jenkins password (via SSM shell)
- `Start an SSM shell session`:
  ```bash
  aws ssm start-session --target <JENKINS_INSTANCE_ID> --region us-east-1
```
Then inside the instance:
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
