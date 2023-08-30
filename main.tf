terraform {
  backend "s3" {}
}

data "aws_caller_identity" "this" {}

resource "aws_s3_bucket" "queries" {
  bucket = "${var.datacollector_name}-queries"
  force_destroy = var.force_bucket_destroy
}

resource "aws_s3_bucket" "data" {
  bucket = "${var.datacollector_name}-data"
  force_destroy = var.force_bucket_destroy
}

resource "aws_iam_role" "collector" {
    count = var.deploy_eks_iamrsa_role ? 1 : 0
    name = "datacollector-${var.datacollector_name}"
    assume_role_policy = data.aws_iam_policy_document.collector_assume[0].json
}

data "aws_iam_policy_document" "collector_assume" {
    count = var.deploy_eks_iamrsa_role ? 1 : 0
    statement {
    sid     = "CollectorAssumeRole"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"

      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:oidc-provider/${var.eks_openid_connect_provider_url}"]
    }

    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"]
      variable = "${var.eks_openid_connect_provider_url}:sub"
    }

    effect = "Allow"
  }

}

data "aws_iam_policy_document" "collector_permissions" {
    count = var.deploy_eks_iamrsa_role ? 1 : 0
    statement {
        effect = "Allow"
        actions = ["s3:*Object","s3:ListBucket"]
        resources = [
            "${aws_s3_bucket.data.arn}",
            "${aws_s3_bucket.data.arn}/*",
        ]
    }
}

resource "aws_iam_role_policy_attachment" "collector" {
    count = var.deploy_eks_iamrsa_role ? 1 : 0
    role = aws_iam_role.collector[0].name
    policy_arn = aws_iam_policy.collector[0].arn
}

resource "aws_iam_policy" "collector" {
    count = var.deploy_eks_iamrsa_role ? 1 : 0
    name = "datacollector-${var.datacollector_name}"
    policy = data.aws_iam_policy_document.collector_permissions[0].json

}

resource "aws_athena_database" "collector" {
  name   = var.datacollector_name
  bucket = aws_s3_bucket.queries.id
}

resource "aws_glue_catalog_table" "collector" {
    name = "${var.datacollector_name}_data"
    database_name = aws_athena_database.collector.name

    depends_on = [aws_athena_database.collector]

    table_type = "EXTERNAL_TABLE"

    parameters = {
        EXTERNAL = "TRUE"
        classification = "json"
        comment = "${var.datacollector_name}"
    }

    storage_descriptor {
        location = "s3://${aws_s3_bucket.data.id}/"
        input_format = "org.apache.hadoop.mapred.TextInputFormat"
        output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
        ser_de_info {
            serialization_library = "org.openx.data.jsonserde.JsonSerDe"
            parameters = {
                "mapping" = "TRUE"
                "serialization.format" = 1
                "ignore.malformed.json" = "FALSE"
                "dots.in.keys" = "FALSE"
                "case.insensitive" = "TRUE"
            }
        }

        columns {
            name = "name"
            type = "string"
        }

        columns {
            name = "labels"
            type = "map<string,string>"
        }

        columns {
            name = "value"
            type = "float"
        }

        columns {
            name = "help"
            type = "string"
        }

        columns {
            name = "type"
            type = "string"
        }

        columns {
            name = "date"
            type = "timestamp"
        }
    }
    
}