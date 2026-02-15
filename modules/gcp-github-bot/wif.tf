# Pool de Identidad
resource "google_iam_workload_identity_pool" "pool" {
  workload_identity_pool_id = "${var.app_name}-pool"
}

# Proveedor OIDC
resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
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

# IAM: Permisos para GitHub (Impersonation)
resource "google_service_account_iam_member" "github_impersonation" {
  service_account_id = google_service_account.vm_sa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/attribute.repository/${var.github_owner}/${var.github_repo}"
}

# IAM: Permisos para que la SA gestione la VM
resource "google_project_iam_member" "roles" {
  for_each = toset([
    "roles/compute.instanceAdmin.v1",
    "roles/compute.osAdminLogin",
    "roles/iam.serviceAccountUser"
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.vm_sa.email}"
}