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

###################################
# Firewall (Equivalent to AWS SG)
####################################

variable "allowed_ports" {
  type = list(string)
  default = [ "22", "80" ]
}

resource "google_compute_firewall" "main" {
    name    = "allow-ssh1"
    network = "default"

    dynamic "allow" {
      for_each = var.allowed_ports
      content {
        protocol = "tcp"
        ports = [allow.value]
      }
    }

    source_ranges = [
      "0.0.0.0/0",
      "15.97.103.44/32"
    ]
}

resource "google_compute_instance" "default" {
  name         = "test"
  machine_type = var.web_instance_type

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

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
    <h1>Hello this is module-1 at instance id $INSTANCE_ID</h1>
  </body>
</html>
HTML

systemctl enable apache2
systemctl restart apache2
EOF

  depends_on = [google_compute_firewall.main]
}


###################################
# Outputs
####################################
output "instance_public_ip" {
  value = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}

output "web_url" {
  value = "http://${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}"
}
