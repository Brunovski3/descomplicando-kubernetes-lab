output "vm_public_ips" {
  value = { for i, vm in azurerm_linux_virtual_machine.vm : vm.name => azurerm_public_ip.pip[i].ip_address }
}

output "ssh_commands" {
  value = { for i, vm in azurerm_linux_virtual_machine.vm : vm.name => "ssh ${var.admin_username}@${azurerm_public_ip.pip[i].ip_address}" }
}
