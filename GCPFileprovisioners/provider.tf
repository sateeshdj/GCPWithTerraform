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
  name         = "test"
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
      // Ephemeral IP
    }
  }

metadata = {
  enable-serial-port = "true"
  ssh-keys = "debian:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJFCBaivwSqFwVp2h8RJzChY7HGNVg3RTlwOXVJnbBWNtu66mCLeBMjB67OVxai+6sCJm8e9vZ5ow3lmtN5G40/81LtRcIMJrI0LrTw4VqEpGkUAOACeJhOajhPCPWV2pGjYi3yUJayqa3Ss0ku7GhCglMWNnJCR6XHp+DHe187aOk/W/fUUDxwvltdd4d0ybq3QZDICL8jY+G0l1zm86gWmLbJDWjzrZn/Ihp25h3RvvUM6WmpxY9pG6OMTcgxZeeGW+fC9FJlHaLMRpu91I9ZKjv++ft1wPkoIo55Frdu+jt5ns3k9zOJ0rAwUk2iYYUE/pTnIHmie5UrIYFWzdvxGCpm/yZe1BUDIHFoutfoYy8rJyQiLYEipMYdI5Cohuc30BG0aM2BW/ABNmNLRXigaNNDnI9Obel8ep7j9TK7Khy3WRMCAK6euAHrBoTXNJv/vYzY7U6udTcW+O1L38I042M5Sbv7Bp2gri1pd2lTYg5axlXNJ3ozslBp15l45G+RmhIo+a59p2OkrF7E+mKeImZZtk3fqaTWKWdwp/afvbjG2gyN+5YRNnX77vd4eiXgRaUqp1SUgQma4Nm634LidkjjfyRUMtUnhEDqSfws1WRJNoT93uh+wi1auAfPklQzJNH4j69NHsD9U2Hi81JUPOF5/aqiJpUWJI75nmzZw== sateeshdj@cs-451828982951-default" 
 }

provisioner "file" {
  source = "/home/sateeshdj/GCP/GCPFileprovisioners/testfile"
  destination = "/home/sateeshdj/test-file.txt"
}

connection {
 type = "ssh"
 host = self.network_interface[0].access_config[0].nat_ip
 user = "sateeshdj"
 private_key = file("/home/sateeshdj/GCP/GCPFileprovisioners/sateeshgenkey")
 timeout = "4m"
}

depends_on = [
    google_compute_firewall.main
  ]
}

resource "google_compute_firewall" "main" {
  name    = "allow-ssh1"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}

