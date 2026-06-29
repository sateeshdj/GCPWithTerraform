terraform {
  required_providers {
    google = {
        source = "Hashicorp/google"
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

resource "google_compute_instance" "datasourcetest" {
  name         = "test"
  machine_type = var.instance_type
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
     }
  }

   # To keep the setup simple you can set the network_interface to default
  # For Advance network setup refer to Point-7 : Setup Network and Firewall for virtual machine
  network_interface {
    network = "default"
    access_config {}
  }

  tags = ["datasourcetest"]
  labels = {
    name = "datasourcetest"
  }
}

variable "instance_type" {
    description = "Instance type of machine"
    type = string
    default = "e2-micro"
}

data "google_compute_instance" "datasourceinstance" {
    name = "test"
    zone = "europe-west1-b"
    depends_on = [ 
        google_compute_instance.datasourcetest 
        ]
}

output "datasourceoutput" {
    value = data.google_compute_instance.datasourceinstance.network_interface[0].access_config[0].nat_ip
}
