resource "azurerm_virtual_network" "virtual_network" {
	name				= var.prefix
	resource_group_name	= var.resource_group["name"]
	address_space		= var.vnet_address_space
	location			= var.resource_group["location"]

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-vnet"
	})
}

resource "azurerm_subnet" "public_dmz" {
	name					= "public-dmz"
	resource_group_name		= var.resource_group["name"]
	virtual_network_name	= azurerm_virtual_network.virtual_network.name
	address_prefixes		= [cidrsubnet(azurerm_virtual_network.virtual_network.address_space[0], 3, 0)]
}

resource "azurerm_subnet" "private_app" {
	name					= "private-app"
	resource_group_name		= var.resource_group["name"]
	virtual_network_name	= azurerm_virtual_network.virtual_network.name
	address_prefixes		= [cidrsubnet(azurerm_virtual_network.virtual_network.address_space[0], 3, 1)]
	service_endpoints		= ["Microsoft.Sql", "Microsoft.Storage"]
}

resource "azurerm_subnet" "private_data" {
	name					= "private-data"
	resource_group_name		= var.resource_group["name"]
	virtual_network_name	= azurerm_virtual_network.virtual_network.name
	address_prefixes		= [cidrsubnet(azurerm_virtual_network.virtual_network.address_space[0], 3, 2)]
}

resource "azurerm_network_security_group" "private_app" {
	name				= "${var.prefix}-private-app"
	location			= var.resource_group["location"]
	resource_group_name	= var.resource_group["name"]

	security_rule {
		name						= "AllowAllSelfSn"
		description					= "Allow all from self subnet"
		priority					= 100
		direction					= "Inbound"
		access						= "Allow"
		protocol					= "*"
		source_port_range			= "*"
		destination_port_range		= "*"
		source_address_prefix		= azurerm_subnet.private_app.address_prefix
		destination_address_prefix	= "*"
	}

	security_rule {
		name						= "AllowHttpAppGwSn"
		description					= "Allow HTTP connection from application gateway subnets"
		priority					= 300
		direction					= "Inbound"
		access						= "Allow"
		protocol					= "*"
		source_port_range			= "*"
		destination_port_ranges		= [80, 443]
		source_address_prefixes		= [for index in range(0, 5) : cidrsubnet(azurerm_virtual_network.virtual_network.address_space[0], 3, 3 + index)]
		destination_address_prefix	= "*"
	}

	security_rule {
		name						= "AllowAllDmzSn"
		description					= "Allow all from DMZ subnets"
		priority					= 301
		direction					= "Inbound"
		access						= "Allow"
		protocol					= "*"
		source_port_range			= "*"
		destination_port_range		= "*"
		source_address_prefix		= azurerm_subnet.public_dmz.address_prefix
		destination_address_prefix	= "*"
	}

	security_rule {
		name						= "DenyAllAll"
		description					= "Deny all from all"
		priority					= 1999
		direction					= "Inbound"
		access						= "Deny"
		protocol					= "*"
		source_port_range			= "*"
		destination_port_range		= "*"
		source_address_prefix		= "*"
		destination_address_prefix	= "*"
	}

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-private-app-nsg"
		Zone	= "Private"
	})
}

resource "azurerm_network_security_group" "private_data" {
	name				= "${var.prefix}-private-data"
	location			= var.resource_group["location"]
	resource_group_name	= var.resource_group["name"]

	security_rule {
		name						= "AllowAllSelfSn"
		description					= "Allow all from data subnets"
		priority					= 100
		direction					= "Inbound"
		access						= "Allow"
		protocol					= "*"
		source_port_range			= "*"
		destination_port_range		= "*"
		source_address_prefix		= azurerm_subnet.private_data.address_prefix
		destination_address_prefix	= "*"
	}

	security_rule {
		name						= "AllowAllAppSn"
		description					= "Allow all from application subnets"
		priority					= 300
		direction					= "Inbound"
		access						= "Allow"
		protocol					= "*"
		source_port_range			= "*"
		destination_port_range		= "*"
		source_address_prefix		= azurerm_subnet.private_app.address_prefix
		destination_address_prefix	= "*"
	}

	security_rule {
		name						= "DenyAllAll"
		description					= "Deny all from all"
		priority					= 1999
		direction 					= "Inbound"
		access						= "Deny"
		protocol					= "*"
		source_port_range			= "*"
		destination_port_range		= "*"
		source_address_prefix		= "*"
		destination_address_prefix	= "*"
	}

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-private-data-nsg"
		Zone	= "Private"
	})
}

resource "azurerm_route_table" "public" {
	name				= "${var.prefix}-public"
	location			= var.resource_group["location"]
	resource_group_name	= var.resource_group["name"]

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-public-rtb"
		Zone	= "Public"
	})
}

resource "azurerm_route" "public_internal" {
	count	= length(azurerm_virtual_network.virtual_network.address_space[*])

	name				= "Internal-${format("%02d", count.index)}"
	resource_group_name	= var.resource_group["name"]
	route_table_name	= azurerm_route_table.public.name
	address_prefix		= azurerm_virtual_network.virtual_network.address_space[count.index]
	next_hop_type		= "VnetLocal"
}

resource "azurerm_route" "public_internet" {
	name				= "Internet"
	resource_group_name	= var.resource_group["name"]
	route_table_name	= azurerm_route_table.public.name
	address_prefix		= "0.0.0.0/0"
	next_hop_type		= "Internet"
}

resource "azurerm_route_table" "private" {
	name				= "${var.prefix}-private"
	location			= var.resource_group["location"]
	resource_group_name	= var.resource_group["name"]

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-private-rtb"
		Zone	= "Private"
	})
}

resource "azurerm_route" "private_internal" {
	count	= length(azurerm_virtual_network.virtual_network.address_space[*])

	name				= "Internal-${format("%02d", count.index)}"
	resource_group_name	= var.resource_group["name"]
	route_table_name	= azurerm_route_table.private.name
	address_prefix		= azurerm_virtual_network.virtual_network.address_space[count.index]
	next_hop_type		= "VnetLocal"
}

resource "azurerm_route" "private_internet" {
	count	= length(azurerm_network_interface.nat[*].private_ip_address)

	name					= "Internet"
	resource_group_name		= var.resource_group["name"]
	route_table_name		= azurerm_route_table.private.name
	address_prefix			= "0.0.0.0/0"
	next_hop_type			= "VirtualAppliance"
	next_hop_in_ip_address	= azurerm_network_interface.nat[0].private_ip_address
}

resource "azurerm_subnet_network_security_group_association" "private_app" {
	subnet_id					= azurerm_subnet.private_app.id
	network_security_group_id	= azurerm_network_security_group.private_app.id
}

resource "azurerm_subnet_network_security_group_association" "private_data" {
	subnet_id					= azurerm_subnet.private_data.id
	network_security_group_id	= azurerm_network_security_group.private_data.id
}

resource "azurerm_subnet_route_table_association" "public_dmz" {
	subnet_id		= azurerm_subnet.public_dmz.id
	route_table_id	= azurerm_route_table.public.id
}

resource "azurerm_subnet_route_table_association" "private_app" {
	subnet_id		= azurerm_subnet.private_app.id
	route_table_id	= azurerm_route_table.private.id
}

resource "azurerm_subnet_route_table_association" "private_data" {
	subnet_id		= azurerm_subnet.private_data.id
	route_table_id	= azurerm_route_table.private.id
}