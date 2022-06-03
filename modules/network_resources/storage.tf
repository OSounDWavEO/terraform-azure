resource "azurerm_storage_account" "storage" {
	name						= lower(replace(var.prefix, "-", ""))
	resource_group_name			= var.resource_group["name"]
	location					= var.resource_group["location"]
	account_kind				= "StorageV2"
	account_tier				= "Standard"
	account_replication_type	= "ZRS"

	tags	= merge(var.tags, {
		Name	= "${var.prefix}-storage"
	})

	lifecycle {
		ignore_changes	= [account_replication_type]
	}
}