# Habilitar Compute Engine API
resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
}

# Habilitar IAM API (para roles y instance profiles)
resource "google_project_service" "iam" {
  project = var.project_id
  service = "iam.googleapis.com"
}

# Habilitar Cloud Logging (opcional, si quieres usar logging)
resource "google_project_service" "logging" {
  project = var.project_id
  service = "logging.googleapis.com"
}

# VPC
resource "google_compute_network" "main" {
  name                    = "${var.project}-vpc"
  auto_create_subnetworks = false
}

# Public Subnet
resource "google_compute_subnetwork" "public" {
  name          = "${var.project}-public-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.main.id
}

#Firewall
resource "google_compute_firewall" "allow_http" {
  name    = "${var.project}-allow-http"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.project}-allow-ssh"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Service Account
resource "google_service_account" "vm_sa" {
  account_id   = "${var.project}-vm-sa"
  display_name = "VM Service Account"
}

# Startup Script
data "template_file" "init" {
  template = file("${path.module}/../provision/user_data.tpl")

  vars = {
    telegram_bot_token = var.telegram_bot_token
    APP_DIR            = "/opt/telegram_bot"
    APP_USER           = "telegram"
    APP_NAME           = "telegram-bot"
    ENV_FILE           = "/etc/telegram-bot.env"
  }

}

# VM
resource "google_compute_instance" "telegram_bot" {
  name         = "${var.project}-vm"
  machine_type = "e2-micro"
  zone         = "${var.region}-a"

  tags = ["telegram-bot"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.public.id

    access_config {
      # IP pública
    }
  }

  metadata = {
    startup-script = data.template_file.init.rendered
  }

  service_account {
    email  = google_service_account.vm_sa.email
    scopes = ["cloud-platform"]
  }

  depends_on = [google_project_service.compute]
}

