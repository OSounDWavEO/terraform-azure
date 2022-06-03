resource "azurerm_subnet" "app_gateway" {
	name					= "app-gateway-${var.name}"
	resource_group_name		= var.resource_group["name"]
	virtual_network_name	= var.virtual_network["name"]
	address_prefixes		= [cidrsubnet(var.virtual_network.address_space, 3, 3 + var.subnet_number)]
	service_endpoints		= ["Microsoft.KeyVault"]
}