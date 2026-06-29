terraform {
  required_version = ">= 0.12"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = "gcpterraform-490307"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}

####################################
# Firewall (Equivalent to AWS SG)
####################################
resource "google_compute_firewall" "webserver_fw" {
  name    = "webserver-fw"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [
    "0.0.0.0/0",        # HTTP
    "115.97.103.44/32"  # SSH
  ]
}

####################################
# GCP Compute Instance
####################################
resource "google_compute_instance" "web" {
  name         = "gcp-webserver"
  machine_type = "e2-micro"
  tags         = ["webserver"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
    access_config {}   # Ephemeral public IP
  }

  ####################################
  # SSH Key (Equivalent to aws_key_pair)
  ####################################
  metadata = {
    ssh-keys = "debian:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJFCBaivwSqFwVp2h8RJzChY7HGNVg3RTlwOXVJnbBWNtu66mCLeBMjB67OVxai+6sCJm8e9vZ5ow3lmtN5G40/81LtRcIMJrI0LrTw4VqEpGkUAOACeJhOajhPCPWV2pGjYi3yUJayqa3Ss0ku7GhCglMWNnJCR6XHp+DHe187aOk/W/fUUDxwvltdd4d0ybq3QZDICL8jY+G0l1zm86gWmLbJDWjzrZn/Ihp25h3RvvUM6WmpxY9pG6OMTcgxZeeGW+fC9FJlHaLMRpu91I9ZKjv++ft1wPkoIo55Frdu+jt5ns3k9zOJ0rAwUk2iYYUE/pTnIHmie5UrIYFWzdvxGCpm/yZe1BUDIHFoutfoYy8rJyQiLYEipMYdI5Cohuc30BG0aM2BW/ABNmNLRXigaNNDnI9Obel8ep7j9TK7Khy3WRMCAK6euAHrBoTXNJv/vYzY7U6udTcW+O1L38I042M5Sbv7Bp2gri1pd2lTYg5axlXNJ3ozslBp15l45G+RmhIo+a59p2OkrF7E+mKeImZZtk3fqaTWKWdwp/afvbjG2gyN+5YRNnX77vd4eiXgRaUqp1SUgQma4Nm634LidkjjfyRUMtUnhEDqSfws1WRJNoT93uh+wi1auAfPklQzJNH4j69NHsD9U2Hi81JUPOF5/aqiJpUWJI75nmzZw== sateeshdj@cs-451828982951-default"
  }

  ####################################
  # Startup Script (AWS user_data)
  ####################################
  metadata_startup_script = <<EOF
#!/bin/bash
apt-get update -y
apt-get install -y apache2

INSTANCE_ID=$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/id \
  -H "Metadata-Flavor: Google")

cat <<HTML > /var/www/html/index.html
<html>
  <body>
    <h1>Hello this is module-2 at instance id $INSTANCE_ID</h1>
  </body>
</html>
HTML

systemctl enable apache2
systemctl restart apache2
EOF

  depends_on = [google_compute_firewall.webserver_fw]
}

####################################
# Outputs
####################################
output "instance_public_ip" {
  value = google_compute_instance.web.network_interface[0].access_config[0].nat_ip
}

output "web_url" {
  value = "http://${google_compute_instance.web.network_interface[0].access_config[0].nat_ip}"
}
