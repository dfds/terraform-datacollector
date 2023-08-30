output "data_bucket" {
    value = aws_s3_bucket.data.id
    description = "Name of the S3 data bucket containing collected data"
}

output "queries_bucket" {
    value = aws_s3_bucket.queries.id
    description = "Name of the S3 data bucket containing queries and results"
}

output "database_name" {
    value = aws_athena_database.collector.name
    description = "Name of the Athena database for the data collector"
}

output "table_name" {
    value = aws_glue_catalog_table.collector.name
    description = "Name of the Glue table for the data collector"
}

output "iam_role_arn" {
    value = var.deploy_eks_iamrsa_role ? aws_iam_role.collector[0].arn : null
    description = "ARN of the IAM role to use for EKS IAM RSA authentication if enabled"
}