output "virtual_network" {
	value	= {
		id				= azurerm_virtual_network.virtual_network.id
		name			= azurerm_virtual_network.virtual_network.name
		address_space	= azurerm_virtual_network.virtual_network.address_space[0]
	}
}

output "subnet_ids" {
	value	= {
		public_dmz		= azurerm_subnet.public_dmz.id
		private_app		= azurerm_subnet.private_app.id
		private_data	= azurerm_subnet.private_data.id
	}
}

output "nat_lb_pool" {
	value	= length(azurerm_lb_backend_address_pool.nat[*].id) > 0 ? azurerm_lb_backend_address_pool.nat[0].id : null

	depends_on	= [azurerm_lb_backend_address_pool.nat[0]]
}

output "storage_account" {
	value	= azurerm_storage_account.storage.id
}