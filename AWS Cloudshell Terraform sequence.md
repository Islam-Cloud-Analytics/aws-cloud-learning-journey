# SETUP: Install Terraform in CloudShell
```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
terraform version
```

# SETUP: Create Directory Structure
```bash
mkdir -p ~/terraform-infra/environments
cd ~/terraform-infra
```

# CREATE: variables.tf
```bash
cat > variables.tf << 'EOF'
<file content>
EOF
```

# CREATE: main.tf
```bash
cat > main.tf << 'EOF'
<file content>
EOF
```

# CREATE: outputs.tf
```bash
cat > outputs.tf << 'EOF'
<file content>
EOF
```

# SETUP: Initialize Terraform
```bash
terraform init
```

# SETUP: Create Workspaces
```bash
terraform workspace new production
terraform workspace new testing
terraform workspace list
```

# CREATE: Production Environment Variables
```bash
cat > environments/production.tfvars << 'EOF'
environment    = "production"
aws_region     = "us-east-1"
vpc_cidr       = "10.0.0.0/16"
public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
instance_type  = "t3.small"
alert_email    = "YOUR_EMAIL@example.com"
EOF
```

# DEPLOY: Production Environment
```bash
terraform workspace select production
terraform plan -var-file="environments/production.tfvars"
terraform apply -var-file="environments/production.tfvars" -auto-approve
```

# CREATE: Testing Environment Variables
```bash
cat > environments/testing.tfvars << 'EOF'
environment    = "testing"
aws_region     = "us-east-1"
vpc_cidr       = "10.1.0.0/16"
public_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
instance_type  = "t3.micro"
alert_email    = "YOUR_EMAIL@example.com"
EOF
```

# DEPLOY: Testing Environment
```bash
terraform workspace select testing
terraform plan -var-file="environments/testing.tfvars"
terraform apply -var-file="environments/testing.tfvars" -auto-approve
```

# VERIFY: Check Resources
```bash
aws sns list-topics
aws sts get-caller-identity
```

# CLEANUP: Destroy Testing Environment (if needed)
```bash
terraform workspace select testing
terraform destroy -var-file="environments/testing.tfvars"
aws sns delete-topic --topic-arn arn:aws:sns:us-east-1:ACCOUNT_ID:testing-alerts
```
