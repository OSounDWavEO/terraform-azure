data "azurerm_platform_image" "app" {
	location	= var.resource_group["location"]
	publisher	= var.vm_app_image["publisher"]
	offer		= var.vm_app_image["offer"]
	sku			= var.vm_app_image["sku"]
}

data "azurerm_platform_image" "nfs" {
	location	= var.resource_group["location"]
	publisher	= var.vm_nfs_image["publisher"]
	offer		= var.vm_nfs_image["offer"]
	sku			= var.vm_nfs_image["sku"]
}

data "azurerm_platform_image" "redis" {
	location	= var.resource_group["location"]
	publisher	= var.vm_redis_image["publisher"]
	offer		= var.vm_redis_image["offer"]
	sku			= var.vm_redis_image["sku"]
}

data "azurerm_private_dns_zone" "internal_dns_zone" {
  name                = var.internal_root_domain
  resource_group_name = var.internal_dns_resource_group
}