provider "google" {
  project = var.gcp_project_id
  region  = "us-central1"
}

data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

locals {
  project_id     = var.gcp_project_id
  region         = "us-central1"
  replica_set    = "rs-analytics"
  node_zones     = ["us-central1-a", "us-central1-b", "us-central1-c"]
  network_name   = "mongodb-network"
  subnet_name    = "mongodb-subnet"
  startup_script = file("${path.module}/scripts/startup-script.sh")
}

resource "google_project_service" "compute" {
  project            = local.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_network" "mongodb" {
  project                 = local.project_id
  name                    = local.network_name
  auto_create_subnetworks = false

  depends_on = [google_project_service.compute]
}

resource "google_compute_subnetwork" "mongodb" {
  project       = local.project_id
  name          = local.subnet_name
  ip_cidr_range = "10.42.0.0/24"
  network       = google_compute_network.mongodb.id
  region        = local.region
}

resource "google_compute_firewall" "mongodb_replication" {
  project       = local.project_id
  name          = "mongodb-allow-replication"
  network       = google_compute_network.mongodb.name
  direction     = "INGRESS"
  source_ranges = [google_compute_subnetwork.mongodb.ip_cidr_range]
  target_tags   = ["mongodb"]

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }
}

resource "google_compute_address" "mongodb" {
  count = length(local.node_zones)

  project      = local.project_id
  name         = "mongodb-${count.index + 1}-internal-ip"
  region       = local.region
  subnetwork   = google_compute_subnetwork.mongodb.id
  address_type = "INTERNAL"
}

resource "google_compute_disk" "mongodb_data" {
  count = length(local.node_zones)

  project = local.project_id
  name    = "mongodb-${count.index + 1}-data"
  zone    = local.node_zones[count.index]
  type    = "pd-ssd"
  size    = 500
}

resource "google_compute_instance_template" "mongodb" {
  project      = local.project_id
  name_prefix  = "mongodb-node-"
  machine_type = "n2-standard-8"
  tags         = ["mongodb"]

  disk {
    source_image = data.google_compute_image.ubuntu.self_link
    auto_delete  = true
    boot         = true
    disk_type    = "pd-balanced"
    disk_size_gb = 50
  }

  network_interface {
    subnetwork = google_compute_subnetwork.mongodb.id

    # Nodes need egress for OS and MongoDB package installation.
    access_config {}
  }

  metadata = {
    mongo-seed-ip = google_compute_address.mongodb[0].address
  }

  metadata_startup_script = local.startup_script

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_from_template" "mongodb" {
  count = length(local.node_zones)

  project                  = local.project_id
  name                     = "mongodb-${count.index + 1}"
  zone                     = local.node_zones[count.index]
  source_instance_template = google_compute_instance_template.mongodb.self_link_unique

  network_interface {
    subnetwork = google_compute_subnetwork.mongodb.id
    network_ip = google_compute_address.mongodb[count.index].address

    access_config {}
  }

  attached_disk {
    source      = google_compute_disk.mongodb_data[count.index].self_link
    device_name = "mongodb-data"
    mode        = "READ_WRITE"
  }
}
