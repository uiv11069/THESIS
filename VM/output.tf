output "vm_name" {
  value       = azurerm_linux_virtual_machine.vm.name
  description = "Name of the virtual machine"
}

output "vm_private_ip" {
  value       = azurerm_network_interface.vm_nic.ip_configuration[0].private_ip_address
  description = "Private IP address of the virtual machine"
}
