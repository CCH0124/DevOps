provider "google" {
    credentials = file("../possible-dream-303312-e316c3595b22.json")
    project = "possible-dream-303312"
    region = "us-central1"
    zone = "us-central1-c"
}

resource "google_compute_instance" "vm_instance" {
    name = "tf-vm"
    machine_type = "e2-micro"

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-10"
        }
    }
    network_interface {
        network = "default"
        access_config {
        // Ephemeral IP
        }
    }

    metadata_startup_script = "echo hi > /test.txt"
}