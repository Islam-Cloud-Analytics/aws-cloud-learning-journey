
# Destroy and Rebuild Guide with SSH Keys

  

## What's New in This Version

  

✅ **SSH Key Pairs** - Automatically generated and saved

✅ **IAM Role for SSM** - Session Manager will work

✅ **SSM Agent** - Pre-installed via user-data

✅ **Stress Testing Tool** - Pre-installed for alarm testing

  

---

  

## Step 1: Destroy Existing Infrastructure

  

### **Destroy Production:**

```bash

cd  ~/terraform-infra

  

# Switch to production workspace

terraform  workspace  select  production

  

# Destroy

terraform  destroy  -var-file=environments/production.tfvars

# Type 'yes' when prompted

```

  

### **Destroy Testing:**

```bash

# Switch to testing workspace

terraform  workspace  select  testing

  

# Destroy

terraform  destroy  -var-file=environments/testing.tfvars

# Type 'yes' when prompted

```

  

### **Clean Up Old Files:**

```bash

# Remove old state and modules

rm  -rf  .terraform  terraform.tfstate.d/  *.tfplan

  

# Remove old SSH keys (if any)

rm  -f  *.pem

```

  

---

  

## Step 2: Backup and Replace Files

  

### **Backup Current Files:**

```bash

cd  ~/terraform-infra

mkdir  -p  ../backup

cp  -r  *  ../backup/

```

  

### **Replace with New Files:**

  

**Option A: Download files I provided above and upload them**

  

**Option B: Copy directly in CloudShell:**

  

```bash

cd  ~/terraform-infra

  

# Remove old files

rm  main.tf  variables.tf  outputs.tf

  

# Create new main.tf

cat  >  main.tf  <<  'EOF'

[Copy entire main.tf content from file I provided]

EOF

  

# Create new variables.tf

cat  >  variables.tf  <<  'EOF'

[Copy entire variables.tf content from file I provided]

EOF

  

# Create new outputs.tf

cat  >  outputs.tf  <<  'EOF'

[Copy entire outputs.tf content from file I provided]

EOF

```

  

---

  

## Step 3: Update Environment Variables

  

### **Edit production.tfvars:**

```bash

nano  environments/production.tfvars

```

  

Change:

```hcl

alert_email = "your-actual-prod-email@example.com"

```

  

### **Edit testing.tfvars:**

```bash

nano  environments/testing.tfvars

```

  

Change:

```hcl

alert_email = "your-actual-test-email@example.com"

```

  

---

  

## Step 4: Initialize Terraform

  

```bash

cd  ~/terraform-infra

  

# Initialize (downloads new providers and modules)

terraform  init

  

# Verify workspaces exist (or recreate them)

terraform  workspace  list

  

# If workspaces don't exist:

terraform  workspace  new  production

terraform  workspace  new  testing

```

  

---

  

## Step 5: Deploy Production

  

```bash

# Select production workspace

terraform  workspace  select  production

  

# Plan

terraform  plan  -var-file=environments/production.tfvars

  

# Review the plan carefully - should show:

# - VPC, subnets, security group

# - EC2 instance with IAM role

# - SSH key pair

# - S3 bucket

# - SNS topic

# - CloudWatch alarms

  

# Apply

terraform  apply  -var-file=environments/production.tfvars

# Type 'yes' when prompted

```

  

**Wait 3-5 minutes for deployment**

  

---

  

## Step 6: Deploy Testing

  

```bash

# Select testing workspace

terraform  workspace  select  testing

  

# Plan

terraform  plan  -var-file=environments/testing.tfvars

  

# Apply

terraform  apply  -var-file=environments/testing.tfvars

# Type 'yes' when prompted

```

  

**Wait 3-5 minutes for deployment**

  

---

  

## Step 7: Verify SSH Access

  

### **Get SSH Connection Info:**

```bash

terraform  workspace  select  production

terraform  output  ssh_connection_command

```

  

Example output:

```

ssh -i ./production-terraform-key.pem ec2-user@3.238.45.123

```

  

### **Test SSH Connection:**

```bash

# Use the command from output

ssh  -i  ./production-terraform-key.pem  ec2-user@<public-ip>

  

# If successful, you'll get shell prompt

# Exit with: exit

```

  

### **Repeat for Testing:**

```bash

terraform  workspace  select  testing

terraform  output  ssh_connection_command

ssh  -i  ./testing-terraform-key.pem  ec2-user@<public-ip>

```

  

---

  

## Step 8: Verify Session Manager

  

### **Check in AWS Console:**

```

1. Systems Manager → Session Manager → Start session

2. You should now see both instances listed

3. Click instance → Start session

4. Browser terminal opens (no SSH key needed!)

```

  

### **Test SSM Agent:**

```bash

# In Session Manager terminal:

sudo  systemctl  status  amazon-ssm-agent

# Should show: active (running)

```

  

---

  

## Step 9: Confirm SNS Subscriptions

  

**Check both emails (production and testing) for SNS confirmation emails.**

  

Click the confirmation link in each email.

  

---

  

## Step 10: Test CloudWatch Alarms

  

### **Test CPU Alarm:**

  

**Via SSH:**

```bash

ssh  -i  ./production-terraform-key.pem  ec2-user@<production-ip>

  

# Stress CPU

stress  --cpu  4  --timeout  300

  

# Wait 3-5 minutes, check email for alarm notification

```

  

**Via Session Manager:**

```

1. Session Manager → Connect to production instance

2. Run: stress --cpu 4 --timeout 300

3. Wait for email alert

```

  

### **Test S3 Alarm:**

```bash

# Generate 4xx errors

for  i  in {1..15}; do

curl  https://production-static-website-xxxxx.s3.amazonaws.com/fake-file-$i.html

done

  

# Wait 5-10 minutes for alarm

```

  

---

  

## Post-Deployment Verification

  

### **Check All Resources:**

  

```bash

# Production

terraform  workspace  select  production

terraform  state  list

terraform  output

  

# Testing

terraform  workspace  select  testing

terraform  state  list

terraform  output

```

  

### **Expected Outputs:**

  

**Production:**

```

vpc_id = "vpc-xxxxx"

ec2_instance_id = "i-xxxxx"

ec2_public_ip = "3.238.45.123"

ssh_key_name = "production-terraform-key"

ssh_private_key_path = "./production-terraform-key.pem"

ssh_connection_command = "ssh -i ./production-terraform-key.pem ec2-user@3.238.45.123"

s3_bucket_name = "production-static-website-xxxxx"

sns_topic_arn = "arn:aws:sns:us-east-1:xxxxx:production-alerts"

iam_role_name = "production-ec2-ssm-role"

```

  

**Testing:**

```

[Similar outputs with 'testing' prefix]

```

  

---

  

## Important Files Generated

  

After deployment, you'll have these new files:

  

```

terraform-infra/

├── main.tf

├── variables.tf

├── outputs.tf

├── environments/

│ ├── production.tfvars

│ └── testing.tfvars

├── production-terraform-key.pem # SSH private key for production

├── testing-terraform-key.pem # SSH private key for testing

└── .terraform/ # Downloaded modules

```

  

**⚠️ NEVER commit .pem files to Git!**

  

---

  

## Troubleshooting

  

### **Issue: SSH Connection Refused**

```bash

# Wait 2-3 minutes after deployment

# EC2 instance needs time to boot

  

# Check instance is running:

aws  ec2  describe-instances  --instance-ids  <instance-id>  --query  'Reservations[0].Instances[0].State.Name'

```

  

### **Issue: Session Manager Still Empty**

```bash

# Wait 5 minutes for SSM agent to register

# Check SSM agent status via SSH:

ssh  -i  ./production-terraform-key.pem  ec2-user@<ip>

sudo  systemctl  status  amazon-ssm-agent

  

# If not running:

sudo  systemctl  start  amazon-ssm-agent

```

  

### **Issue: SSH Permission Denied**

```bash

# Fix key permissions

chmod  400  production-terraform-key.pem

chmod  400  testing-terraform-key.pem

```

  

### **Issue: No Email Confirmation**

```bash

# Check spam folder

# Or resend via console:

# SNS → Topics → Select topic → Subscriptions → Request confirmation

```

  

---

  

## Clean Destroy (If Needed)

  

```bash

# Destroy both environments completely

terraform  workspace  select  production

terraform  destroy  -var-file=environments/production.tfvars

  

terraform  workspace  select  testing

terraform  destroy  -var-file=environments/testing.tfvars

  

# Remove workspaces

terraform  workspace  select  default

terraform  workspace  delete  production

terraform  workspace  delete  testing

```

  

---

  

## Summary of Changes

  

| Feature | Old Setup | New Setup |

|---------|-----------|-----------|

| SSH Access | ❌ No key pair | ✅ Auto-generated keys |

| Session Manager | ❌ No IAM role | ✅ IAM role + SSM agent |

| Alarm Testing | ❌ Can't access instance | ✅ SSH + Session Manager |

| Key Management | ❌ Manual | ✅ Terraform managed |

| SSM Agent | ❌ Not installed | ✅ Pre-installed via user-data |

| Stress Tool | ❌ Not available | ✅ Pre-installed |

  

---

  

## Next Steps After Deployment

  

1. ✅ Download SSH keys to your local machine (if needed)

2. ✅ Test SSH access from your laptop

3. ✅ Upload content to S3 buckets

4. ✅ Test alarm notifications

5. ✅ Document your setup in Git (excluding .pem files)

6. ✅ Create .gitignore with sensitive files

  

**The infrastructure is now complete with full access!** 🎉