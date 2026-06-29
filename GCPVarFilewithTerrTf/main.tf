terraform{
    required_providers{
        google = {
            source = "hashicorp/google"
            version = ">= 5.0"
        }
    }
}

provider "google"{
  project                     = "gcpterraform-490307"
  region                      = "europe-west1"
  zone                        = "europe-west1-b"
  impersonate_service_account = "terraform-sa@gcpterraform-490307.iam.gserviceaccount.com"
}

resource "google_compute_instance" "defualt" {
  name         = "test-01"
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

  }
  
  labels = {
    environment = var.environment_type
  }
}


