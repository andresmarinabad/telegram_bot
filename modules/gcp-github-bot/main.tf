locals {
  resource_prefix = "${var.app_name}"
}

# 1. APIs - La base de todo
resource "google_project_service" "services" {
  for_each = toset([
    "compute.googleapis.com", 
    "iam.googleapis.com", 
    "logging.googleapis.com",
    "cloudresourcemanager.googleapis.com" # Recomendado para gestionar IAM sin errores
  ])
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false # Crucial: evita que el destroy se cuelgue
}

# 2. Network - Depende de las APIs
resource "google_compute_network" "main" {
  name                    = "${local.resource_prefix}-vpc"
  auto_create_subnetworks = false
  
  # Obliga a Terraform a esperar la API antes de intentar LEER o CREAR la red
  depends_on = [google_project_service.services]
}

resource "google_compute_subnetwork" "public" {
  name          = "${local.resource_prefix}-public-subnet"
  ip_cidr_range = var.vpc_cidr
  region        = var.region
  network       = google_compute_network.main.id
  # No necesita depends_on porque ya depende implícitamente de google_compute_network.main
}

# 3. Firewall
resource "google_compute_firewall" "rules" {
  name    = "${local.resource_prefix}-fw-allow-rules"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  source_ranges = var.allowed_ips
}

# 4. Service Account - También requiere la API de IAM activa
resource "google_service_account" "vm_sa" {
  account_id   = "${var.app_name}-sa"
  display_name = "SA for ${var.app_name} and GitHub Actions"
  
  depends_on = [google_project_service.services]
}

# 5. Instancia - El último paso
resource "google_compute_instance" "vm" {
  name         = "${local.resource_prefix}-vm"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.boot_image
      size  = var.boot_size
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.public.id
    access_config {} 
  }

  metadata = {
    startup-script = templatefile("${path.module}/provision/user_data.tpl", var.template_vars)
  }

  service_account {
    email  = google_service_account.vm_sa.email
    scopes = ["cloud-platform"]
  }

  # Al depender de las APIs, aseguras que el ciclo de vida sea correcto
  depends_on = [google_project_service.services]
}