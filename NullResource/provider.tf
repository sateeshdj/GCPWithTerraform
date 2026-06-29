terraform {
  required_providers {
    google = {
        source = "hashicorp/google"
        version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region = var.region_id
  zone = var.zone_id
  impersonate_service_account = var.service_account_id
}

resource "google_compute_instance" "default" {
  name = "test"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  # To keep the setup simple you can set the network_interface to default
  # For Advance network setup refer to Point-7 : Setup Network and Firewall for virtual machine
  network_interface {
    network = "default"

    access_config {
      # Ephemeral IP
    }
  }
}
 
 resource "terraform_data" "test_hello_world" {
    #triggers_replace = {
        #id = google_compute_instance.default.id
    #    id = timestamp()
    #}

    provisioner "local-exec" {
      command = "echo 'hello world ${google_compute_instance.default.name} is now live.'"
    }
 }
