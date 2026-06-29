terraform {
  required_providers {
    google = {
        version = ">= 5.0"
        source = "hashicorp/google"
    }
  }
}

provider "google" {
  project = var.project_id
  region = var.region_id
  zone = var.zone_id
  impersonate_service_account = var.service_account_id
}

module "apache_httpd1" {
  source = ".//module-1"
}

module "apache_httpd2" {
  source = ".//module-2"
}

output "public_ip_ec2" {
  value       = module.apache_httpd1.instance_public_ip
  description = "Public IP of EC2"
}
