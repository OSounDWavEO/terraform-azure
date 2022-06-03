resource "azurerm_network_security_group" "single" {
	name				= "${var.prefix}-single"
	location			= var.resource_group["location"]
	resource_group_name	= var.resource_group["name"]

	security_rule {
		name						= "AllowAllHTTP"
		description					= "Allow HTTP from all"
		priority					= 900
		direction					= "Inbound"
		access						= "Allow"
		protocol					= "Tcp"
		source_port_range			= "*"
		destination_port_range		= "80"
		source_address_prefix		= "*"
		destination_address_prefix	= "*"
	}

	security_rule {
		name						= "AllowAllHTTPS"
		description					= "Allow HTTPS from all"
		priority					= 901
		direction					= "Inbound"
		access						= "Allow"
		protocol					= "Tcp"
		source_port_range			= "*"
		destination_port_range		= "443"
		source_address_prefix		= "*"
		destination_address_prefix	= "*"
	}

	security_rule {
		name						= "DenyAllAll"
		description					= "Deny all from all"
		priority					= 1000
		direction					= "Inbound"
		access						= "Deny"
		protocol					= "*"
		source_port_range			= "*"
		destination_port_range		= "*"
		source_address_prefix		= "*"
		destination_address_prefix	= "*"
	}

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-nsg"
		Zone	= "Public"
	})
}