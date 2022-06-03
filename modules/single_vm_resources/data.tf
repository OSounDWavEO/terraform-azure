data "azurerm_platform_image" "single" {
	location	= var.resource_group["location"]
	publisher	= var.vm_image["publisher"]
	offer		= var.vm_image["offer"]
	sku			= var.vm_image["sku"]
}

data "azurerm_private_dns_zone" "internal_dns_zone" {
  name                = var.internal_root_domain
  resource_group_name = var.internal_dns_resource_group
}