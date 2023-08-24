terraform {
  backend "s3" {}
}

resource "aws_s3_bucket" "queries" {
  bucket = "${var.datacollector_name}-queries"
  force_destroy = var.force_bucket_destroy
}

resource "aws_s3_bucket" "data" {
  bucket = "${var.datacollector_name}-data"
  force_destroy = var.force_bucket_destroy
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