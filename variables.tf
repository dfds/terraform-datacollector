variable "datacollector_name" {
    type = string
    description = "Name of the datacollector. Use no special characters in the naming"
}

variable "force_bucket_destroy" {
    type = bool
    default = false
    description = "Empties both the data and queries buckets on a terraform destroy allowing the buckets to be deleted"
}

# EKS IAM Roles for Service Accounts #
variable "deploy_eks_iamrsa_role" {
    default = false
    description = "Deploys the IAM roles required for EKS IAM RSA authentication"
}

variable "eks_openid_connect_provider_url" {
    type = string
    default = null
    description = "The URL of the OpenID Connect provider"
}

variable "service_account_namespace" {
    type = string
    default = null
    description = "The namespace of the service account"
}

variable "service_account_name" {
    type = string
    default = null
    description = "The name of the service account"
}
# #