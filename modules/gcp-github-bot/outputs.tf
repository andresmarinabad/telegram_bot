output "vm_public_ip" {
  description = "La dirección IP pública de la instancia del bot"
  value       = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}

output "vm_name" {
  description = "El nombre de la instancia creada"
  value       = google_compute_instance.vm.name
}

output "service_account_email" {
  description = "El email de la cuenta de servicio utilizada por GitHub y la VM"
  value       = google_service_account.vm_sa.email
}

output "wif_provider_name" {
  description = "El identificador completo del Workload Identity Provider"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "vpc_name" {
  description = "Nombre de la VPC creada"
  value       = google_compute_network.main.name
}