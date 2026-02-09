# 0. Service Account
resource "google_service_account" "vm_sa_github" {
  account_id   = "${var.project}-vm-sa-github"
  display_name = "GitHub Service Account "
}

# 1. Permiso para que la SA gestione la instancia
resource "google_project_iam_member" "vm_sa_admin" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.vm_sa_github.email}"
}

# 2. Permiso necesario para que el túnel SSH de gcloud funcione
resource "google_project_iam_member" "os_login" {
  project = var.project_id
  role    = "roles/compute.osAdminLogin"
  member  = "serviceAccount:${google_service_account.vm_sa_github.email}"
}

# 3. Crear el Pool de Identidad
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-pool"
}

# 4. Configurar el Proveedor (OIDC)
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }

  attribute_condition = "assertion.repository_owner == '${var.github_owner}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# 5. Darle permiso a GitHub para entrar en la VM
# Nota: La cuenta de servicio debe tener permisos de "Compute Instance Admin"
resource "google_service_account_iam_member" "github_sa_user" {
  service_account_id = google_service_account.vm_sa_github.name
  role               = "roles/iam.serviceAccountUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_owner}/${var.repo}"
}

resource "google_project_iam_member" "sa_user_project" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.vm_sa_github.email}"
}

# 6. Permiso a la SA para impersonate y auto generarse un token de acceso
resource "google_service_account_iam_member" "github_sa_impersonation" {
  service_account_id = google_service_account.vm_sa_github.name
  role               = "roles/iam.serviceAccountTokenCreator" 
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_owner}/${var.repo}"
}

### GitHub Actions ###

# Secreto para el Workload Identity Provider
resource "github_actions_secret" "wif_provider" {
  repository      = var.repo
  secret_name     = "workload_identity_provider"
  plaintext_value = google_iam_workload_identity_pool_provider.github_provider.name
}

# Secreto para el Email de la Service Account
resource "github_actions_secret" "sa_email" {
  repository      = var.repo
  secret_name     = "gcloud_service_account"
  plaintext_value = google_service_account.vm_sa_github.email
}

# Secreto para el Nombre de la VM (útil para el script de deploy)
resource "github_actions_secret" "container_name" {
  repository      = var.repo
  secret_name     = "container_name"
  plaintext_value = google_compute_instance.telegram_bot.name
}

# Secreto para la Zona
resource "github_actions_secret" "vm_zone" {
  repository      = var.repo
  secret_name     = "gcloud_zone"
  plaintext_value = google_compute_instance.telegram_bot.zone
}

# ID del proyecto
resource "github_actions_secret" "project_id" {
  repository      = var.repo
  secret_name     = "gcloud_project_id"
  plaintext_value = var.project_id
}

# TELEGRAM BOT TOKEN
resource "github_actions_secret" "telegram_bot_token" {
  repository      = var.repo
  secret_name     = "telegram_bot_token"
  plaintext_value = var.telegram_bot_token
}