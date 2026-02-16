output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "ec2_instance_id" {
  description = "EC2 Instance ID"
  value       = module.ec2_instance.id
}

output "ec2_public_ip" {
  description = "EC2 Public IP"
  value       = module.ec2_instance.public_ip
}

output "ec2_private_ip" {
  description = "EC2 Private IP"
  value       = module.ec2_instance.private_ip
}

output "ssh_key_name" {
  description = "SSH Key Pair Name"
  value       = aws_key_pair.deployer.key_name
}

output "ssh_private_key_path" {
  description = "Path to SSH private key file"
  value       = local_file.private_key.filename
}

output "ssh_connection_command" {
  description = "SSH connection command"
  value       = "ssh -i ${local_file.private_key.filename} ec2-user@${module.ec2_instance.public_ip}"
}

output "s3_bucket_name" {
  description = "S3 Bucket Name"
  value       = module.s3_bucket.s3_bucket_id
}

output "s3_website_endpoint" {
  description = "S3 Website Endpoint"
  value       = module.s3_bucket.s3_bucket_website_endpoint
}

output "sns_topic_arn" {
  description = "SNS Topic ARN"
  value       = module.sns.topic_arn
}

output "iam_role_name" {
  description = "IAM Role Name for EC2"
  value       = aws_iam_role.ec2_ssm_role.name
}

output "iam_role_arn" {
  description = "IAM Role ARN for EC2"
  value       = aws_iam_role.ec2_ssm_role.arn
}
