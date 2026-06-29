provider "google" {
    project = "gcpterraform-490307"
    region = "europe-west1"
    zone = "europe-west1-b"
}

variable "gmailusers" {
    type = map(string)
    default = { 
            "sateeshdj@gmail.com" = "roles/viewer"
    }
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
    for_each = var.gmailusers
    
    project = "gcpterraform-490307"
    role = each.value
    member  = "user:${each.key}"
}

output "iam_users" {
  value = var.gmailusers
}
