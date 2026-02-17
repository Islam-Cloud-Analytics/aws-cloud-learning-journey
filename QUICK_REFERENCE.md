# Quick Reference Guide
✅ For more details Follow [the guide](https://github.com/Cyber-Nomadness/aws-cloud-learning-journey/blob/main/How%20I%20deployed%20the%20two%20vpcs%20with%20terraform.md) and [commandline cheatsheet](https://github.com/Cyber-Nomadness/aws-cloud-learning-journey/blob/main/AWS%20Cloudshell%20Terraform%20sequence.md) 
## Key Improvements in Updated Templates

### ✅ SSH Key Pairs
- **Auto-generated** per environment
- **Saved locally** as `.pem` files
- **No manual key creation** needed

### ✅ IAM Role for SSM
- **AmazonSSMManagedInstanceCore** policy attached
- **Instance profile** created automatically
- **Session Manager** will work immediately

### ✅ SSM Agent Pre-installed
- **User-data script** installs SSM agent on boot
- **Auto-starts** and enables on startup
- **No manual installation** required

### ✅ Stress Testing Tool
- **Pre-installed** for alarm testing
- Ready to use immediately after deployment

---

## File Structure

```
terraform-infra/
├── main.tf                          # Core infrastructure (NEW VERSION)
├── variables.tf                     # Variable declarations
├── outputs.tf                       # Outputs (with SSH info)
├── .gitignore                       # Protect sensitive files
├── DEPLOYMENT_GUIDE.md              # Complete deployment instructions
├── environments/
│   ├── production.tfvars            # Production values (NOT in Git)
│   ├── testing.tfvars               # Testing values (NOT in Git)
│   ├── production.tfvars.example    # Template (IN Git)
│   └── testing.tfvars.example       # Template (IN Git)
└── [generated after apply]
    ├── production-terraform-key.pem  # SSH key (NOT in Git)
    └── testing-terraform-key.pem     # SSH key (NOT in Git)
```

---

## Quick Commands

### **Destroy Current Infrastructure**
```bash
cd ~/terraform-infra
terraform workspace select production
terraform destroy -var-file=environments/production.tfvars
terraform workspace select testing
terraform destroy -var-file=environments/testing.tfvars
```

### **Deploy New Infrastructure**
```bash
# Update files, then:
terraform init
terraform workspace select production
terraform apply -var-file=environments/production.tfvars
terraform workspace select testing
terraform apply -var-file=environments/testing.tfvars
```

### **Get SSH Command**
```bash
terraform output ssh_connection_command
```

### **Test Alarms**
```bash
# Via SSH
ssh -i ./production-terraform-key.pem ec2-user@<ip>
stress --cpu 4 --timeout 300

# Via Session Manager
# Console → Session Manager → Start session → Select instance
stress --cpu 4 --timeout 300
```

---

## What Gets Created (Per Environment)

| Resource | Quantity | Purpose |
|----------|----------|---------|
| VPC | 1 | Network isolation |
| Subnets | 2 | High availability |
| Security Group | 1 | Firewall rules |
| EC2 Instance | 1 | Compute (RHEL) |
| SSH Key Pair | 1 | SSH access |
| IAM Role | 1 | SSM permissions |
| IAM Instance Profile | 1 | Attach role to EC2 |
| S3 Bucket | 1 | Static website |
| SNS Topic | 1 | Notifications |
| CloudWatch Alarms | 3 | Monitoring |

**Total per environment: 13 resources**  
**Total for both: 26 resources**

---

## Access Methods After Deployment

### **1. SSH (With Key)**
```bash
ssh -i ./production-terraform-key.pem ec2-user@<public-ip>
```

### **2. Session Manager (Browser)**
```
AWS Console → Systems Manager → Session Manager → Start session
```

### **3. EC2 Instance Connect (Browser)**
```
AWS Console → EC2 → Connect → EC2 Instance Connect
```

**All three methods will work!**

---

## Security Notes

### **DO commit to Git:**
✅ main.tf, variables.tf, outputs.tf
✅ .gitignore
✅ *.tfvars.example
✅ Documentation

### **DO NOT commit to Git:**
❌ *.tfvars (contains emails)
❌ *.pem (SSH private keys)
❌ terraform.tfstate* (contains sensitive data)
❌ .terraform/ (downloaded modules)

---

## Differences from Previous Version

| Feature | Old | New |
|---------|-----|-----|
| SSH Keys | ❌ None | ✅ Auto-generated |
| Session Manager | ❌ Broken | ✅ Works immediately |
| SSM Agent | ❌ Not installed | ✅ Pre-installed |
| IAM Role | ❌ Missing | ✅ Included |
| Alarm Testing | ❌ Can't access | ✅ Can test via SSH/SSM |
| Stress Tool | ❌ Not available | ✅ Pre-installed |
| TLS Provider | ❌ Not used | ✅ For key generation |

---

## Terraform Providers Used

1. **AWS** (~> 5.0) - Main infrastructure
2. **Random** (~> 3.0) - S3 bucket suffix
3. **TLS** (~> 4.0) - SSH key generation
4. **Local** (built-in) - Save SSH keys locally

---

## Cost Estimate (Per Environment)

| Resource | Monthly Cost |
|----------|-------------|
| VPC | $0.00 (free) |
| EC2 t3.micro | ~$7.50 |
| S3 Bucket | ~$0.10 |
| CloudWatch Alarms | ~$0.30 |
| SNS | ~$0.01 |
| **Total** | **~$8/month** |

**Both environments: ~$16/month**

---

## Troubleshooting Quick Fixes

### Problem: Permission denied (publickey)

→ `chmod 400 *.pem`  
→ `ls -l your-key.pem`  
→ `ssh -i your-key.pem ec2-user@your-instance-ip`  
→ Different AMIs use different usernames:
  - Amazon Linux/Amazon Linux 2: `ec2-user`
  - RHEL: `ec2-user` or `root`
  - Ubuntu: `ubuntu`
  - Debian: `admin` or `debian`  
→ In case your key is in a different location use the full path:
  - `ssh -i ~/path/to/your-key.pem ec2-user@your-instance-ip`

### Problem: Session Manager shows no instances

→ Wait 5 minutes, then check SSM agent status

### Problem: No SNS confirmation email

→ Check spam folder, or resend from SNS console

### Problem: Alarms not triggering

→ Stress test for 5+ minutes (2 evaluation periods needed)

---

## Next Steps
1. ✅Test all access methods
2. ✅Upload S3 content
3. ✅ Test alarms
4. ✅  Document the findings in my project repo
5. ✅ Feedback and advice are welcome
