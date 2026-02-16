# Multi-Environment Infrastructure with SSH Keys and SSM Support
# Updated version with key pairs and proper IAM roles

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Random suffix for unique S3 bucket names
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Generate SSH Key Pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = "${var.environment}-terraform-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Save private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/${var.environment}-terraform-key.pem"
  file_permission = "0400"
}

# Data source for RHEL AMI
data "aws_ami" "rhel" {
  most_recent = true
  owners      = ["309956199498"] # Red Hat owner ID

  filter {
    name   = "name"
    values = ["RHEL-9*_HVM-*-x86_64-*"] # RHEL 9 (change to RHEL-10* when available)
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM Role for EC2 SSM Access
resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.environment}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-ec2-ssm-role"
    Environment = var.environment
  }
}

# Attach SSM Policy to Role
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ec2-instance-profile"
  role = aws_iam_role.ec2_ssm_role.name

  tags = {
    Name        = "${var.environment}-ec2-profile"
    Environment = var.environment
  }
}

# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs            = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets = var.public_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
    Terraform   = "true"
  }
}

# Security Group Module
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.environment}-sg"
  description = "Security group for ${var.environment} environment"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "SSH"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "HTTP"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "HTTPS"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
      description = "All outbound"
    }
  ]

  tags = {
    Name        = "${var.environment}-sg"
    Environment = var.environment
  }
}

# EC2 Instance Module with SSM and SSH
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name = "${var.environment}-rhel-instance"

  ami                         = data.aws_ami.rhel.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.deployer.key_name
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [module.security_group.security_group_id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Install SSM Agent on RHEL
    sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
    sudo systemctl start amazon-ssm-agent
    sudo systemctl enable amazon-ssm-agent
    
    # Update system
    sudo dnf update -y
    
    # Install stress tool for testing
    sudo dnf install -y stress
  EOF
  )

  root_block_device = [
    {
      volume_type = "gp3"
      volume_size = 10
      encrypted   = true
    }
  ]

  tags = {
    Name        = "${var.environment}-rhel-instance"
    Environment = var.environment
    OS          = "RHEL"
  }
}

# S3 Bucket Module for Static Website
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = "${var.environment}-static-website-${random_id.bucket_suffix.hex}"

  # Keep private for now (avoid Block Public Access issues)
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  website = {
    index_document = "index.html"
    error_document = "error.html"
  }

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "${var.environment}-static-website"
    Environment = var.environment
  }
}

# SNS Topic Module
module "sns" {
  source  = "terraform-aws-modules/sns/aws"
  version = "~> 6.0"

  name = "${var.environment}-alerts"

  subscriptions = {
    email = {
      protocol = "email"
      endpoint = var.alert_email
    }
  }

  tags = {
    Name        = "${var.environment}-alerts"
    Environment = var.environment
  }
}

# CloudWatch Alarm - EC2 CPU
module "ec2_cpu_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 5.0"

  alarm_name          = "${var.environment}-ec2-cpu-high"
  alarm_description   = "CPU utilization is too high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_actions       = [module.sns.topic_arn]

  dimensions = {
    InstanceId = module.ec2_instance.id
  }

  tags = {
    Name        = "${var.environment}-ec2-cpu-alarm"
    Environment = var.environment
  }
}

# CloudWatch Alarm - EC2 Status Check
module "ec2_status_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 5.0"

  alarm_name          = "${var.environment}-ec2-status-check"
  alarm_description   = "EC2 instance status check failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_actions       = [module.sns.topic_arn]

  dimensions = {
    InstanceId = module.ec2_instance.id
  }

  tags = {
    Name        = "${var.environment}-ec2-status-alarm"
    Environment = var.environment
  }
}

# CloudWatch Alarm - S3 4xx Errors
resource "aws_cloudwatch_metric_alarm" "s3_4xx_errors" {
  alarm_name          = "${var.environment}-s3-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "4xxErrors"
  namespace           = "AWS/S3"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "S3 bucket experiencing high 4xx errors"
  alarm_actions       = [module.sns.topic_arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    BucketName = module.s3_bucket.s3_bucket_id
    FilterId   = "EntireBucket"
  }

  tags = {
    Name        = "${var.environment}-s3-4xx-alarm"
    Environment = var.environment
  }
}
