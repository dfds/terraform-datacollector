remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "my-tf-state-bucket"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-locks"
  }
}