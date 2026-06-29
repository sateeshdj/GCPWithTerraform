terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
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

resource "google_compute_instance" "default" {
  name         = "test-${count.index}"
  machine_type = var.instance_type
  count = var.instance_count

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  # To keep the setup simple you can set the network_interface to default
  # For Advance network setup refer to Point-7 : Setup Network and Firewall for virtual machine
  network_interface {
    network = "default"

  dynamic "access_config" {
      for_each = var.enable_public_ip ? [1] : []
      content {}
    }

  }

  labels = var.Labels

}

resource "google_service_account" "example" {
  count = length(var.User_Names)
  account_id = var.User_Names[count.index]
  display_name = "Service account for ${var.User_Names[count.index]}"
}

variable "instance_type" {
   description = "Instance type e2-micro"
   type        = string
   default     = "e2-micro"
}

variable "instance_count" {
   description = "Instance count e2-micro"
   type        = number
   default     = 2
}

variable "enable_public_ip" {
   description = "Enable public IP address"
   type        = bool
   default     = true
}

variable "User_Names" {
   description = "List of IAM user names"
   type        = list(string)
   default     = ["user1-sa", "user2-sa", "user3-sa"]
}

variable "Labels" {
   description = "Labels to MAP"
   type        = map(string)
   default     =  {
       project = "gcp_terraform"
       environment = "dev"
   }
}