output "vm_id" {
	value	= azurerm_virtual_machine.single.name
}

output "vm_internal_dns" {
	value = {
		"name"	= "${var.prefix}.${var.internal_root_domain}"
		"type"	= "A"
		"value"	= azurerm_network_interface.single.private_ip_address
	}
}

output "vm_ni" {
	value	= azurerm_network_interface.single.id
}