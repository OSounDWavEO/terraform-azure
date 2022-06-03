data "azurerm_private_dns_zone" "internal_dns_zone" {
  name                = var.internal_root_domain
  resource_group_name = var.internal_dns_resource_group
}