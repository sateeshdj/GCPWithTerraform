#!/bin/bash
set -euo pipefail

PROJECT="gcpterraform-490307"
REGION_PRI="europe-west1"        # South India equivalent
ZONE_PRI="europe-west1-b"

REGION_GEO="europe-west1"        # Central India equivalent
ZONE_GEO="europe-west1-b"

VM_MACHINE_TYPE="n2-standard-16"

# PRi VM
PRI_VM="provitgstc-kodpocvmpri"
PRI_NET="pri-vpc"
PRI_SUBNET="pri-subnet"
PRI_CIDR="10.132.0.0/20"
PRI_FIREWALL="pri-office-allow"

PRI_BOOT_DISK="test-clone1"
PRI_DATA_DISKS=(
  "test-data-clone1"
)

# GEO VM
GEO_VM="provitgstc-kodpocvmgeo"
GEO_NET="geo-vpc"
GEO_SUBNET="geo-subnet"
GEO_CIDR="10.142.0.0/20"
GEO_FIREWALL="geo-office-allow"

GEO_BOOT_DISK="geo-bootdisk"
GEO_DATA_DISKS=(
  "geo-data0"
  "geo-data1"
  "geo-data2"
  "geo-data3"
  "geo-data4"
)

# Office IPs
OFFICE_IPS=(
  "182.73.35.38/32"
  "202.122.17.158/32"
  "182.75.75.76/30"
  "122.15.167.184/30"
  "122.160.122.48/29"
)

gcloud config set project "$PROJECT"

ensure_network() {
  local net="$1"
  if gcloud compute networks describe "$net" >/dev/null 2>&1; then
    echo "VPC exists: $net"
  else
    echo "Creating VPC: $net"
    gcloud compute networks create "$net" --subnet-mode=custom
  fi
}

ensure_subnet() {
  local net="$1" subnet="$2" region="$3" cidr="$4"
  if gcloud compute networks subnets describe "$subnet" --region "$region" >/dev/null 2>&1; then
    echo "Subnet exists: $subnet"
  else
    echo "Creating subnet: $subnet"
    gcloud compute networks subnets create "$subnet" \
      --network "$net" \
      --region "$region" \
      --range "$cidr"
  fi
}

ensure_firewall() {
  local name="$1" net="$2"
  if gcloud compute firewall-rules describe "$name" >/dev/null 2>&1; then
    echo "Updating firewall rule: $name"
    gcloud compute firewall-rules update "$name" \
      --source-ranges "$(IFS=,; echo "${OFFICE_IPS[*]}")" \
      --allow tcp,udp,icmp
  else
    echo "Creating firewall rule: $name"
    gcloud compute firewall-rules create "$name" \
      --network "$net" \
      --source-ranges "$(IFS=,; echo "${OFFICE_IPS[*]}")" \
      --allow tcp,udp,icmp
  fi
}

ensure_vm() {
  local vm="$1" zone="$2" net="$3" subnet="$4" bootdisk="$5"

  if gcloud compute instances describe "$vm" --zone "$zone" >/dev/null 2>&1; then
    echo "VM exists: $vm"
  else
    echo "Creating VM: $vm"
    gcloud compute instances create "$vm" \
      --zone "$zone" \
      --machine-type "$VM_MACHINE_TYPE" \
      --network "$net" \
      --subnet "$subnet" \
      --disk "boot=yes,auto-delete=no,mode=rw,name=$bootdisk"
  fi
}

attach_disks() {
  local vm="$1" zone="$2"; shift
  local disks=("$@")

  for disk in "${disks[@]}"; do
    echo "Attaching $disk to $vm..."
    if gcloud compute instances describe "$vm" --zone "$zone" | grep "$disk" >/dev/null; then
      echo "$disk already attached"
    else
      gcloud compute instances attach-disk "$vm" \
        --disk="$disk" \
        --zone="$zone"
    fi
  done
}

echo "=== PRIMARY VM ==="
ensure_network "$PRI_NET"
ensure_subnet  "$PRI_NET" "$PRI_SUBNET" "$REGION_PRI" "$PRI_CIDR"
ensure_firewall "$PRI_FIREWALL" "$PRI_NET"
ensure_vm "$PRI_VM" "$ZONE_PRI" "$PRI_NET" "$PRI_SUBNET" "$PRI_BOOT_DISK"
attach_disks "$PRI_VM" "$ZONE_PRI" "${PRI_DATA_DISKS[@]}"

echo "=== GEO VM ==="
ensure_network "$GEO_NET"
ensure_subnet  "$GEO_NET" "$GEO_SUBNET" "$REGION_GEO" "$GEO_CIDR"
ensure_firewall "$GEO_FIREWALL" "$GEO_NET"
ensure_vm "$GEO_VM" "$ZONE_GEO" "$GEO_NET" "$GEO_SUBNET" "$GEO_BOOT_DISK"
attach_disks "$GEO_VM" "$ZONE_GEO" "${GEO_DATA_DISKS[@]}"

echo "=== DONE ==="
gcloud compute instances list --filter="name:($PRI_VM $GEO_VM)"