terraform {
  source = "git::https://github.com/dfds/terraform-datacollector.git//?ref=v1.0.0"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
    datacollector_name = "examplecollector"
}
