resource "azurerm_public_ip" "nat" {
	count	= var.enable_nat ? 1 : 0

	name				= "${var.prefix}-nat"
	resource_group_name	= var.resource_group["name"]
	location			= var.resource_group["location"]
	allocation_method	= "Static"
	sku					= "Standard"

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-nat-public-ip"
		Zone	= "Public"
	})
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_link" {
	name					= azurerm_virtual_network.virtual_network.name
	resource_group_name		= var.internal_dns_resource_group
	private_dns_zone_name	= data.azurerm_private_dns_zone.internal_dns_zone.id
	virtual_network_id		= azurerm_virtual_network.virtual_network.id

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-private-dns-link"
		Zone	= "Private"
	})
}