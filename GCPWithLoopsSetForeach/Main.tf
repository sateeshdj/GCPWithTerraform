provider "google" {
    project = "gcpterraform-490307"
    region = "europe-west1"
    zone = "europe-west1-b"
}

variable "gmailusers" {
    type = list(string)
    default = [ "sateeshdj@gmail.com" ]
}

locals {
  my_list = tolist(var.gmailusers)
}

resource "google_compute_instance" "gcpvm" {
    name = "test"
    machine_type = "e2-micro"

    boot_disk {
      initialize_params {
        image = "debian-cloud/debian-12"
      }
    }  

    network_interface {
       network = "default"
       access_config {}
    }
}

resource "google_project_iam_member" "iamuser" {
    for_each = toset(local.my_list)
    
    project = "gcpterraform-490307"
    role = "roles/viewer"
    member  = "user:${each.value}"
}

output "iam_users" {
  value = local.my_list
}
