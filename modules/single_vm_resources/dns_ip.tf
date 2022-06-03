resource "azurerm_public_ip" "single" {
	name				= var.prefix
	resource_group_name	= var.resource_group["name"]
	location			= var.resource_group["location"]
	allocation_method	= "Static"
	sku					= "Standard"

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-public-ip"
		Zone	= "Public"
	})
}

resource "azurerm_private_dns_a_record" "single" {
	name					= var.prefix
	resource_group_name		= var.internal_dns_resource_group
	private_dns_zone_name	= data.azurerm_private_dns_zone.internal_dns_zone.id
	ttl						= 300
	records					= [azurerm_network_interface.single.private_ip_address]

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-private-dns"
		Zone	= "Private"
	})
}