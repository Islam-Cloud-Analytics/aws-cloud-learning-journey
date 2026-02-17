# AWS Multi-Environment Infrastructure with Terraform

A production-ready AWS infrastructure deployment showcasing Infrastructure as Code (IaC) best practices. Implements isolated production and testing environments with automated monitoring, alerting, and security controls.

---

##  AWS Dual Environment Infrastructure
![AWS Infrastructure Diagram](AWS%20Dual%20Environment%20Simple%20Architecture.svg)

---

## Key Features

- Multi-environment infrastructure (Production + Testing) managed with Terraform workspaces
- Automated EC2 provisioning with RHEL 9 and AWS Systems Manager (SSM) integration
- CloudWatch monitoring with SNS email alerts for CPU, status checks, and S3 errors
- S3-hosted static websites with encryption and versioning
- Infrastructure as Code following AWS best practices
- Automated SSH key generation and secure IAM role management
  
  ---

## Technologies Used

- **Infrastructure as Code:** Terraform (AWS provider ~> 5.0)
- **Cloud Platform:** AWS (VPC, EC2, S3, CloudWatch, SNS, IAM)
- **Compute:** RHEL 9 EC2 instances with SSM
- **Monitoring:** CloudWatch Alarms + SNS
- **Deployment:** AWS CloudShell

---

## Quick Start

1. Install Terraform on AWS CloudShell
2. Create workspaces: `terraform workspace new production`
3. Deploy: `terraform apply -var-file="production.tfvars"`

📖 **[Full Deployment Guide →](HOW_I_DEPLOYED_THE_TWO_VPCS_WITH_TERRAFORM.md)**  
📋 **[Command Reference →](QUICK_REFERENCE.md)**

---

## Project Structure
```
├── main.tf                           # Main infrastructure configuration
├── variables.tf                      # Variable definitions
├── outputs.tf                        # Output values
├── production.tfvars.example         # Production environment variables (template)
├── testing.tfvars.example            # Testing environment variables (template)
├── architecture.svg                  # Architecture diagram
├── HOW_I_DEPLOYED_...md             # Detailed deployment walkthrough
└── QUICK_REFERENCE.md               # Command reference
```
---

## Security Notes

**DO NOT commit to Git:**  
❌ *.tfvars (contains emails) | ❌ *.pem (SSH private keys) | ❌ terraform.tfstate* (sensitive data) | ❌ .terraform/ (downloaded modules)

**DO commit:**  
✅ main.tf, variables.tf, outputs.tf | ✅ .gitignore | ✅ *.tfvars.example | ✅ Documentation

---

## Learning Outcomes

- Managing multi-environment infrastructure with Terraform workspaces
- Implementing AWS security best practices (IAM roles, Security Groups, SSM)
- Setting up automated monitoring and alerting systems
- Working with Terraform modules from the official registry
- Infrastructure state management and version control

---

## Documentation

- **[Deployment Guide](HOW_I_DEPLOYED_THE_TWO_VPCS_WITH_TERRAFORM.md)** - Step-by-step deployment process
- **[Quick Reference](QUICK_REFERENCE.md)** - Common commands and configurations
- **[The Deployment SOP](AWS_CLOUDSHELL_TERRAFORM_Multienvironment_SOP.md)** - sanitized commands history from CloudShell from the start

  ---

  ## Author

Built as part of my cloud engineering learning journey.

[My LinkedIn](https://www.linkedin.com/in/islamzayd/) | [My Business Intelligence Project](https://github.com/Islam-Cloud-Analytics/sql-data-analysis-leprosy-caribbean)


---

**⭐ Star this repo if you find it helpful!**

  
