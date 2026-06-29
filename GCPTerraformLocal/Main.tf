terraform{
    required_providers{
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
    staging_type = "staging"
}

resource "google_compute_network" "staging_vpc" {
  name = "${local.staging_type}-vpc"
  auto_create_subnetworks = false

}

resource "google_compute_subnetwork" "staging_subnet" {
  name = "${local.staging_type}-subnet"
  ip_cidr_range =  "10.5.0.0/16"
  network = google_compute_network.staging_vpc.id
}

resource "google_compute_instance" "default" {
  name         = "test-01"
  machine_type = "e2-micro"
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
     subnetwork = google_compute_subnetwork.staging_subnet.id
     access_config {}
     }

   labels = {
    environment = "${local.staging_type}"
  }
  }

  output "my_console_output" {
    value = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
  }
  