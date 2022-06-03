resource "azurerm_private_dns_a_record" "admin" {
	name				= "${var.prefix}-admin"
	zone_name			= data.azurerm_private_dns_zone.internal_dns_zone.id
	resource_group_name	= var.internal_dns_resource_group
	ttl					= 300
	records				= [var.separate_admin ? azurerm_network_interface.admin[0].private_ip_address : azurerm_network_interface.app[0].private_ip_address]

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-private-admin-dns"
		Zone	= "Private"
	})
}

resource "azurerm_private_dns_a_record" "app" {
	// initiate loop
	count = var.vm_app_count

	name				= "${var.prefix}-app-${format("%02d", count.index)}"
	zone_name			= data.azurerm_private_dns_zone.internal_dns_zone.id
	resource_group_name	= var.internal_dns_resource_group
	ttl					= 300
	records				= [azurerm_network_interface.app[count.index].private_ip_address]

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-private-app-${format("%02d", count.index)}-dns"
		Zone	= "Private"
	})
}

resource "azurerm_private_dns_a_record" "nfs" {
	// initiate loop
	count	= var.separate_nfs ? 1 : 0

	name				= "${var.prefix}-nfs"
	zone_name			= data.azurerm_private_dns_zone.internal_dns_zone.id
	resource_group_name	= var.internal_dns_resource_group
	ttl					= 300
	records				= [azurerm_network_interface.nfs[0].private_ip_address]

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-private-nfs-dns"
		Zone	= "Private"
	})
}

resource "azurerm_private_dns_a_record" "redis" {
	// initiate loop
	count = var.vm_redis_count

	name				= "${var.prefix}-redis-${format("%02d", count.index)}"
	zone_name			= data.azurerm_private_dns_zone.internal_dns_zone.id
	resource_group_name	= var.internal_dns_resource_group
	ttl					= 300
	records				= [azurerm_network_interface.redis[count.index].private_ip_address]

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-private-redis-${format("%02d", count.index)}-dns"
		Zone	= "Private"
	})
}

resource "azurerm_private_dns_cname_record" "db_primary" {
	// initiate loop
	count	= var.db_count

	name				= "${var.prefix}-db-00"
	zone_name			= data.azurerm_private_dns_zone.internal_dns_zone.id
	resource_group_name	= var.internal_dns_resource_group
	ttl					= 300
	record				= azurerm_mysql_server.db_primary[count.index].fqdn

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-private-db-00-dns"
		Zone	= "Private"
	})

	lifecycle {
		ignore_changes	= [
			record
		]
	}
}