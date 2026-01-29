# Architecture Decisions (decisions.md)

This document captures the agreed architecture decisions for the **NAS Financial Group AWS Migration Project**.  
It acts as an “architecture contract” to keep implementation consistent across Terraform modules and Jenkins CI/CD.

---

## 1. Project Scope

- NAS Financial Group is migrating selected workloads from on-prem to AWS.
- This is a **project implementation** designed to reflect **real-life AWS best practices**.
- Deployment is managed using **Terraform (IaC)** and a **Jenkins pipeline**.

---

## 2. AWS Account & Identity Model

### Account Model
- **Single AWS account** for NAS Financial Group workloads.
- A **separate AWS account** will be created for the external auditor (**N2G Auditing**) to simulate real cross-account access.

### Identity Approach
- Prefer **IAM roles and policies** (assume Identity Center/SSO-style access in real life).
- Avoid creating large numbers of IAM users with long-term access keys.

### Required Access Groups (Role-Based)
1. **CloudSpace Engineers**
   - Admin-level access to manage AWS resources
   - **Billing access explicitly denied**
2. **NAS Security Team**
   - Full admin access
   - **Billing access included**
3. **NAS Operations Team**
   - Admin permissions **restricted to `us-east-1` only**
   - Explicit deny for all other regions using policy conditions
4. **N2G Auditing**
   - Access comes from **their own AWS account**
   - Uses **cross-account IAM role assumption** into NAS account
   - Permissions limited to:
     - Viewing intranet via HTTP (network-controlled)
     - Database access (least privilege)
     - Centralized best-practice review service only (see Section 7)

---

## 3. Regions & Availability Strategy

### Primary Region
- **`us-east-1`** (main production region)

### Disaster Recovery / Backup Region
- Secondary region used for **cross-region backups** (app + database tier backups).
- Exact DR region can be configured in Terraform variables (e.g., `us-west-2`).

### High Availability
- All tier-1 workloads are deployed across **at least 2 Availability Zones**.

---

## 4. Networking Model

### VPC Design
- One VPC in `us-east-1` with:
  - **Public subnets** (multi-AZ)
  - **Private subnets** (multi-AZ)

### Internet Access
- Public resources use an **Internet Gateway**
- Private resources use a **NAT Gateway** for outbound internet access (package updates, patching, outbound calls)

> Note: NAT Gateway is intentionally used despite cost, to follow AWS best practices.

---

## 5. Public Dynamic Website (PCI + HA + Scaling)

### Compute Platform
- **Amazon ECS (Fargate)** for the dynamic web application

### Public Entry
- **Application Load Balancer (ALB)** in public subnets

### Encryption / PCI
- **HTTPS only** for all user traffic
- Use **ACM** for TLS certificates
- HTTP should redirect to HTTPS (no unencrypted user access)

### Scalability & Self-Healing
- ECS Service with:
  - Desired tasks across multiple AZs
  - Auto scaling based on metrics (CPU/Request count)
- ALB health checks for self-healing behavior

### Database
- **Amazon RDS** (Multi-AZ) for high availability

---

## 6. GDPR Geo-Access Requirement

### Goal
- **Only USA customers** can access the **dynamic** website.
- Non-USA traffic must land on a **static website**.

### Approach (Option A)
- **Route 53 Geo Location Routing**
  - US → Dynamic website (ALB / CloudFront depending on implementation)
  - Others → Static website distribution

---

## 7. Static Website (Non-US Visitors)

- Static site hosted on **Amazon S3**
- Fronted by **CloudFront**
- Used as GDPR-compliant landing for non-US traffic

---

## 8. Intranet Application (Private, Not Public)

### Accessibility
- Intranet is **not publicly accessible**
- Deployed into **private subnets** only
- Accessible via **HTTP** (internal requirement)

### Outbound Updates
- Intranet servers/tasks must be able to download packages and updates from the internet
- Achieved via **NAT Gateway** (outbound-only)

### Secure Management
- CloudSpace Engineers manage intranet resources via **AWS Systems Manager (SSM)**
  - No inbound SSH required
  - No public administrative access

---

## 9. External Auditor Access (N2G Auditing)

### Cross-Account Requirement
- N2G operates from **their own AWS account**
- Access is enabled via **cross-account role assumption**

### Access Scope
- N2G is allowed:
  - HTTP access to intranet web interface (controlled by networking/security groups)
  - Restricted database access (least privilege, only what is needed)

### Best Practices Review Service
- N2G must have centralized visibility into best practices:
  - Cost Optimization
  - Performance
  - Security
  - Reliability/Fault Tolerance

✅ Chosen Service: **AWS Well-Architected Tool**  
- N2G console permissions should grant **full access to Well-Architected Tool ONLY**
- No access to other AWS services

---

## 10. Monitoring & Alerting (Minimum 2 Systems)

### Monitoring System 1 (AWS Native)
- **CloudWatch metrics + alarms**
- Alerts via **SNS**

### Monitoring System 2 (Additional)
- **Route 53 Health Checks** for endpoint availability
- Route 53 health check alarms notify via SNS

Goal: Receive notifications if the website is down or unhealthy.

---

## 11. Backup & Disaster Recovery

### Requirements
- Application tier and database tier must be backed up in a different location.

### Approach
- Use **AWS Backup** and/or scheduled snapshots
- Enable **cross-region copies** of backups/snapshots to the DR region
- RDS automated backups + snapshot policies as needed

---

## 12. Storage for PII (Encryption + Lifecycle)

### Requirements
- Customer files contain **PII**
- Must be encrypted at rest
- Frequently accessed for **30 days**
- Archived and retained for **5 years**

### Storage Solution
- **Amazon S3** with:
  - **SSE-KMS encryption**
  - Lifecycle rules:
    - S3 Standard (0–30 days)
    - Transition to **Glacier** / **Deep Archive**
    - Retention for 5 years (then expiration if required)

---

## 13. Infrastructure as Code & CI/CD

### Terraform
- Use modular Terraform structure:
  - `modules/` for reusable components
  - `envs/prod/` for environment-specific configuration
- Remote state recommended (S3 + DynamoDB locking)

### Jenkins
- Jenkins pipeline automates Terraform workflow:
  - `terraform fmt` / `validate`
  - `terraform plan`
  - Manual approval
  - `terraform apply`

> Jenkins will be hosted following best practices (private access where possible, minimal exposure).

---

## 14. Implementation Order (Build Sequence)

1. IAM (roles, policies, restrictions)
2. Networking (VPC, subnets, IGW, NAT, routing)
3. Storage baseline (S3 + KMS + lifecycle)
4. Dynamic site (ECS Fargate + ALB + ACM + RDS)
5. Static site (S3 + CloudFront)
6. Route 53 geo routing (GDPR routing)
7. Intranet (private ECS/EC2 + internal access + NAT + SSM management)
8. N2G cross-account access (role trust + least privilege)
9. Monitoring (CloudWatch + Route 53 health checks + SNS)
10. Backups & DR (AWS Backup + cross-region copy)
11. Jenkins pipeline (Terraform CI/CD)

---
