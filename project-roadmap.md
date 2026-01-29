# 🗺️ Project Roadmap – NAS Financial AWS Cloud Architecture

This roadmap outlines the phased approach used to design and implement a secure, highly available, and compliant AWS cloud architecture for NAS Financial Group.
The project follows AWS best practices, Infrastructure as Code (Terraform), and CI/CD automation using Jenkins.

Note: This roadmap represents the implementation strategy and may evolve as the project progresses.

### Phase 0 – Scope Definition & Assumptions

- Objective: Establish project boundaries and assumptions before implementation.

- Define migration scope from on-premise to AWS

- Select primary region (us-east-1) and secondary region (disaster recovery)

- Assume centralized identity management via IAM Identity Center (SSO)

- Use IAM roles instead of long-term IAM users

- Simulate enterprise multi-team access within a single AWS account

#### Deliverables:

- Project assumptions documented

- Initial README structure

### Phase 1 – High-Level Architecture Design

`Objective`: Design the overall system architecture before provisioning resources.

- Design public dynamic website architecture

- Design static fallback website for non-US traffic (GDPR)

- Design private intranet application architecture

- Define traffic flow and security boundaries

- Identify AWS services required per requirement

#### Deliverables:

- High-level architecture diagram

- Architecture documentation
- 
### Phase 2 – Identity & Access Management (IAM)

`Objective`: Implement secure and least-privilege access controls.

- Create `IAM roles` for:

- CloudSpace Engineers `admin without billing`

- NAS Security Team `full admin with billing` 

- NAS Operations Team `region-restricted to us-east-1`

- N2G Auditing `cross-account limited access`

- Define IAM policies using explicit allow/deny rules

- Implement region-based restrictions using IAM conditions

- Avoid long-term credentials and root account usage

#### Deliverables:

- IAM Terraform module

- IAM access matrix documentation

### Phase 3 – Networking Foundation

- `Objective`: Build a secure and scalable network foundation.

- Create a VPC with appropriate CIDR planning

- Deploy public and private subnets across multiple Availability Zones

- Configure Internet Gateway and NAT Gateway

- Implement route tables and network segmentation

- Apply consistent tagging standards

#### Deliverables:

- Network Terraform module

- Network architecture diagram

### Phase 4 – Public Dynamic Website (Highly Available & Secure)

`Objective`: Deploy a public-facing dynamic application with high availability.

- Deploy Application Load Balancer (HTTPS only)

- Configure Auto Scaling Group across multiple AZs

- Secure traffic using ACM certificates

-bIntegrate CloudFront for global distribution

- Enforce PCI compliance via encrypted traffic

- Enable self-healing and automatic scaling

#### Deliverables: 
- Dynamic website Terraform module

- Security and availability documentation

### Phase 5 – Static Website (GDPR Compliance)

`Objective`: Provide a static fallback site for non-US users.

- Deploy S3 static website

- Integrate CloudFront distribution

- Implement geo-based routing:

- US users → dynamic website

- Non-US users → static website

#### Deliverables:

- Static website Terraform module

- GDPR compliance explanation

### Phase 6 – Private Intranet Application

`Objective`: Deploy a non-public internal application.

- Deploy application servers in private subnets

- Allow outbound internet access via NAT Gateway

- Restrict inbound access to internal users only

- Serve application traffic over HTTP internally

#### Deliverables:

-Intranet Terraform module

- Private access documentation

### Phase 7 – External Auditing Access (N2G Auditing)

`Objective`: Enable controlled third-party access for auditing.

- Implement cross-account IAM role access

- Allow HTTP access to intranet web interface

- Grant limited database access

- Restrict access to only required resources

- Provide centralized best-practice review access using AWS Well-Architected Tool

#### Deliverables:

- Auditing access Terraform module

- Cross-account access documentation

### Phase 8 – Secure Storage & Data Lifecycle Management

`Objective`: Secure customer PII data and optimize storage costs.

- Store customer data in encrypted S3 buckets (KMS)

- Implement lifecycle policies:

- Frequent access (0–30 days)

- Archive for 5 years (Glacier / Deep Archive)

- Enforce least-privilege access to storage

#### Deliverables:

- Storage Terraform module

- Data lifecycle documentation
### Phase 9 – Monitoring, Alerting & Disaster Recovery

`Objective`: Ensure reliability, visibility, and recoverability.

- Implement CloudWatch monitoring and alarms

- Configure Route 53 health checks

- Send alerts via SNS

- Enable cross-region backups for application and database tiers

- Automate snapshot and backup policies

#### Deliverables:

- Monitoring Terraform module

- Disaster recovery strategy documentation

### Phase 10 – CI/CD Automation with Jenkins

`Objective`: Automate infrastructure deployment and validation.

- Implement Jenkins pipeline stages:

`Terraform formatting and validation`

`Terraform plan`

- Manual approval

`Terraform apply`

- Store Terraform state securely

- Enable repeatable and auditable deployments

#### Deliverables:

- Jenkinsfile

- CI/CD pipeline documentation

### Phase 11 – Documentation & Finalization

Objective: Prepare the project for presentation and review.

Finalize project README

Document architecture decisions and trade-offs

Add diagrams and usage instructions

Summarize lessons learned and future improvements

### Deliverables:

- Final README

- Architecture diagrams

- Project summary

 ### Final Outcome

- By following this roadmap, the project delivers:

- Enterprise-grade AWS architecture

- Secure and compliant cloud design

- Infrastructure as Code using Terraform

- CI/CD automation with Jenkins

- Interview-ready documentation and 
