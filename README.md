# DataCollector Terraform Module

This Terraform module deploys:
 - S3 bucket for storing collected data
 - S3 Bucket for Athena queries
 - Athena database
 - AWS glue table

Optionally it can also deploy the following:
 - AWS IAM Role to be used by EKS IAM Roles for Service Accounts

For example usage, please see the /examples directory