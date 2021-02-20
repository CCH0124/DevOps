provider "google" {
    credentials = file("../possible-dream-303312-e316c3595b22.json")
    project = "possible-dream-303312"
    region = "us-central1"
    zone = "us-central1-c"
}

resource "google_compute_network" "default" {
    name = "gke-k8s"
    auto_create_subnetworks = false
}

data "google_container_engine_versions" "default" {
    location = "us-central1-c"
}

resource "google_compute_subnetwork" "default" {
  name                     = "gke-k8s"
  ip_cidr_range            = "10.127.0.0/20"
  network                  = google_compute_network.default.self_link
  region                   = "us-central1"
  private_ip_google_access = true
}

resource "google_container_cluster" "gke-cluster" {
    name = "gke-k8s"
    location = "us-central1-c"
    min_master_version = data.google_container_engine_versions.default.latest_master_version
    network            = google_compute_subnetwork.default.name
    subnetwork         = google_compute_subnetwork.default.name
    initial_node_count = 3

    provisioner "local-exec" {
        when    = destroy
        command = "sleep 90"
    }
}

output "network" {
  value = google_compute_subnetwork.default.network
}

output "subnetwork_name" {
  value = google_compute_subnetwork.default.name
}

output "cluster_name" {
  value = google_container_cluster.gke-cluster.name
}