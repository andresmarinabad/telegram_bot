resource "github_actions_secret" "secrets" {
  for_each = {
    "WIF_PROVIDER"         = google_iam_workload_identity_pool_provider.github.name
    "GCP_SERVICE_ACCOUNT"  = google_service_account.vm_sa.email
    "GCP_PROJECT_ID"       = var.project_id
    "VM_NAME"              = google_compute_instance.vm.name
    "VM_ZONE"              = google_compute_instance.vm.zone
    "TELEGRAM_BOT_TOKEN"   = var.telegram_bot_token
  }

  repository      = var.github_repo
  secret_name     = each.key
  plaintext_value = each.value
}