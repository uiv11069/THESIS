output "aks_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_kube_config" {
  description = "Kube config to connect to AKS"
  value       = azurerm_kubernetes_cluster.aks.kube_admin_config_raw
  sensitive   = true
}
