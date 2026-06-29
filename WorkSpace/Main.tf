terraform {
  required_providers {
    google = {
        source = "hashicorp/google"
        version = ">= 5.0"
    }
  }
}

provider "google" {
  project                     = "gcpterraform-490307"
  region                      = "europe-west1"
  zone                        = "europe-west1-b" 
  impersonate_service_account = "terraform-sa@gcpterraform-490307.iam.gserviceaccount.com"
}

locals {
    instance_name = "${terraform.workspace}-instance"
}

variable "instance_type" {
    description = "Instance type of machine"
    type = string
    default = "e2-micro"
}

resource "google_compute_instance" "gcp_example" {
     name = local.instance_name
     machine_type = var.instance_type
     zone = "europe-west1-b"

     boot_disk {
       initialize_params {
         image = "debian-cloud/debian-12"
       }
     }

     # To keep the setup simple you can set the network_interface to default
     # For Advance network setup refer to Point-7 : Setup Network and Firewall for virtual machine
     network_interface {
    network = "default"
    access_config {}                        # ephemeral public IP
  }

  labels = {
    name        = local.instance_name       # GCP uses labels instead of tags
    environment = terraform.workspace       # dev / staging / prod
  }
}

output "instance_name" {
  value = google_compute_instance.gcp_example.name
}

output "public_ip" {
  value = google_compute_instance.gcp_example.network_interface[0].access_config[0].nat_ip
}

output "workspace" {
  value = "Deployed in workspace: ${terraform.workspace}"
}
