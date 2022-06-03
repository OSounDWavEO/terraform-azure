output "backend_pools" {
	value	= {for backend_pool in flatten([azurerm_application_gateway.app_gateway_v1, azurerm_application_gateway.app_gateway_v2])[0]["backend_address_pool"] :
		backend_pool.name	=> backend_pool.id
	}
}

output "subnet_address_prefix" {
	value	= azurerm_subnet.app_gateway.address_prefix
}