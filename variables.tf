variable "datacollector_name" {
    type = string
    description = "Name of the datacollector. Use no special characters in the naming"
}

variable "force_bucket_destroy" {
    type = bool
    default = false
    description = "Empties both the data and queries buckets on a terraform destroy allowing the buckets to be deleted"
}