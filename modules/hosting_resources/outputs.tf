output "vm_admin_internal_dns" {
	value = {
		"name"	= "${var.prefix}-admin.${var.internal_root_domain}"
		"type"	= "A"
		"value"	= length(azurerm_network_interface.admin[*].private_ip_address) == 0 ? azurerm_network_interface.app[0].private_ip_address : azurerm_network_interface.admin[0].private_ip_address
	}
}

output "vm_app_internal_dns" {
	value	= {for index, value in azurerm_network_interface.app[*].private_ip_address :
		"app-${format("%02d", index)}" => {
			"name"	= "${var.prefix}-app-${format("%02d", index)}.${var.internal_root_domain}",
			"type"	= "A"
			"value"	= value
		}
	}
}

output "vm_nfs_internal_dns" {
	value = {
		"name"	= "${var.prefix}-nfs.${var.internal_root_domain}"
		"type"	= "A"
		"value"	= length(azurerm_network_interface.nfs[*].private_ip_address) == 0 ? (length(azurerm_network_interface.admin[*].private_ip_address) == 0 ? azurerm_network_interface.app[0].private_ip_address : azurerm_network_interface.admin[0].private_ip_address) : azurerm_network_interface.nfs[0].private_ip_address
	}

	depends_on	= [azurerm_private_dns_a_record.nfs[0]]
}

output "vm_redis_internal_dns" {
	value	= {for index, value in azurerm_network_interface.redis[*].private_ip_address :
		"redis-${format("%02d", index)}" => {
			"name"	= "${var.prefix}-redis-${format("%02d", index)}.${var.internal_root_domain}",
			"type"	= "A"
			"value"	= value
		}
	}
}

output "vm_admin_ni" {
	value	= [var.separate_admin ? azurerm_network_interface.admin[0].id : azurerm_network_interface.app[0].id]
}

output "vm_app_ni" {
	value	= azurerm_network_interface.app[*].id
}

output "vm_nfs_ni" {
	value	= [var.separate_nfs ? azurerm_network_interface.nfs[0].id : azurerm_network_interface.app[0].id]

	depends_on	= [azurerm_private_dns_a_record.nfs[0]]
}