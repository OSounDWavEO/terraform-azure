resource "azurerm_mysql_server" "db_primary" {
	// initiate loop
	count	= var.db_count

	name				= "${var.prefix}-00"
	resource_group_name	= var.resource_group["name"]
	location			= var.resource_group["location"]

	sku_name	= "${var.db_sku}_Gen5_${var.db_primary_cpu}"

	storage_mb						= var.db_storage
	backup_retention_days			= 7
	geo_redundant_backup_enabled	= false
	auto_grow_enabled				= false
	administrator_login				= "devops"
	administrator_login_password	= "PleaseChangePass@1234"
	version							= var.db_engine_version
	ssl_enforcement_enabled			= false

	tags	= merge(var.tags, {
		Name		= "${var.prefix}-db-00"
		Zone		= "Private"
		Group		= "${var.prefix}-db"
		Size		= var.db_primary_cpu
	})

	lifecycle {
		ignore_changes	= [name, tags["Name"], administrator_login_password]
	}
}

resource "azurerm_mysql_virtual_network_rule" "private_app_subnet" {
	// initiate loop
	count	= var.db_count

	name				= "${var.prefix}-private-app-subnet"
	resource_group_name	= var.resource_group["name"]
	server_name			= azurerm_mysql_server.db_primary[count.index].name
	subnet_id			= var.subnet_ids["private_app"]

	lifecycle {
		ignore_changes	= [name]
	}
}