variable "instance_type" {
    description = "Instance type of machine"
    type = string
    default = "e2-micro"
}

variable "project_id" {
    description = "project ID of GCP"
    type = string
    default = "gcpterraform-490307"
}

variable "zone_id" {
    description = "zone ID of GCP"
    type = string
    default = "europe-west1-b"
}

variable "region_id" {
    description = "region ID of GCP"
    type = string
    default = "europe-west1"
}

variable "service_account_id" {
    description = "impersonate service account"
    type = string
    default = "terraform-sa@gcpterraform-490307.iam.gserviceaccount.com"
}
