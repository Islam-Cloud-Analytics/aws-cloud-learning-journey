#### SETUP: Install Terraform in CloudShell

<div align="right">
<h3>
```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
terraform version
```

</h3>
</div>

#### SETUP: Create Directory Structure

<div align="right">
<h3>
```bash
mkdir -p ~/terraform-infra/environments
cd ~/terraform-infra
```

</h3>
</div>

#### CREATE: variables.tf

<div align="right">
<h3>
```bash
cat > variables.tf << 'EOF'
<file content>
EOF
```

</h3>
</div>

#### CREATE: main.tf

<div align="right">
<h3>
```bash
cat > main.tf << 'EOF'
<file content>
EOF
```

</h3>
</div>

#### CREATE: outputs.tf

<div align="right">
<h3>
```bash
cat > outputs.tf << 'EOF'
<file content>
EOF
```

</h3>
</div>

#### SETUP: Initialize Terraform

<div align="right">
<h3>
```bash
terraform init
```

</h3>
</div>

#### SETUP: Create Workspaces

<div align="right">
<h3>
```bash
terraform workspace new production
terraform workspace new testing
terraform workspace list
```

</h3>
</div>

#### CREATE: Production Environment Variables

<div align="right">
<h3>
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

</h3>
</div>

#### DEPLOY: Production Environment

<div align="right">
<h3>
```bash
terraform workspace select production
terraform plan -var-file="environments/production.tfvars"
terraform apply -var-file="environments/production.tfvars" -auto-approve
```

</h3>
</div>

#### CREATE: Testing Environment Variables

<div align="right">
<h3>
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

</h3>
</div>

#### DEPLOY: Testing Environment

<div align="right">
<h3>
```bash
terraform workspace select testing
terraform plan -var-file="environments/testing.tfvars"
terraform apply -var-file="environments/testing.tfvars" -auto-approve
```

</h3>
</div>

#### VERIFY: Check Resources

<div align="right">
<h3>
```bash
aws sns list-topics
aws sts get-caller-identity
```

</h3>
</div>

#### CLEANUP: Destroy Testing Environment (if needed)

<div align="right">
<h3>
```bash
terraform workspace select testing
terraform destroy -var-file="environments/testing.tfvars"
aws sns delete-topic --topic-arn arn:aws:sns:us-east-1:ACCOUNT_ID:testing-alerts
```

</h3>
</div>
