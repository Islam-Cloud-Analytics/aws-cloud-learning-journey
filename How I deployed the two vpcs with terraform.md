# Terraform AWS Infrastructure Setup

## Installation & Setup
- Installed Terraform on AWS using CloudShell
- Created two workspaces: **testing** and **production**

## Terraform Configuration Files

### main.tf
Using existing Terraform modules from Terraform registry, prepared the main configuration file containing:
- Multi-Environment Infrastructure with SSH Keys and SSM Support
- Updated version with key pairs and proper IAM roles
- Random suffix for unique S3 bucket names
- Generate SSH Key Pair
- Create AWS Key Pair
- Save private key locally
- Data source for RHEL AMI
- IAM Role for EC2 SSM Access
- Attach SSM Policy to Role
- Create Instance Profile
- VPC Module
- Security Group Module
- EC2 Instance Module with SSM and SSH
- Bootstrap script:
  ```bash
  #!/bin/bash
  # Install SSM Agent on RHEL
  # Update system
  # Install stress tool for testing
  ```
- S3 Bucket Module for Static Website
- SNS Topic Module
- CloudWatch Alarm - EC2 CPU
- CloudWatch Alarm - EC2 Status Check
- CloudWatch Alarm - S3 4xx Errors

### Environment Configuration Files
Two files for the production and testing VPCs:
- **production.tfvars**
- **testing.tfvars**

Each environment file includes the actual variables:
- `aws_region`
- `vpc_cidr`
- `public_subnets`
- `instance_type`
- `alert_email`

### variables.tf
Prepared the variables.tf which includes - you guessed it!, variables and their descriptions and types:
- `aws_region`
- `environment`
- `public_subnets`
- `instance_type`
- `alert_email`

### outputs.tf
Contains the resultant services, their descriptions and values:
- `vpc_id`
- `ec2_instance_id`
- `ec2_public_ip`
- `ec2_private_ip`
- `ssh_key_name`
- `ssh_private_key_path`
- `ssh_connection_command`
- `s3_bucket_name`
- `s3_website_endpoint`
- `sns_topic_arn`
- `iam_role_name`
- `iam_role_arn`

## Deployment Process

### Production Environment
- Initiated `terraform plan` on the production.tfvars inside the production workspace
- Executed `terraform apply` on the production.tfvars inside the production workspace

### Testing Environment
- Initiated `terraform plan` on the testing.tfvars inside the testing workspace
- Initiated `terraform apply` on the testing.tfvars inside the testing workspace