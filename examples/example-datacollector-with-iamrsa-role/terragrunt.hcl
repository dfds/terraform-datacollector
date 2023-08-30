terraform {
  source = "git::https://github.com/dfds/terraform-datacollector.git//?ref=v1.1.0"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
    datacollector_name = "examplecollectoreks"

    deploy_eks_iamrsa_role = true
    service_account_namespace = "my-namespace"
    service_account_name = "my-service-account"
    eks_openid_connect_provider_url="oidc.eks.my-region-1.amazonaws.com/id/AAAABBBBCCCCAAAABBBBAAAABBBBAAAA"
}
