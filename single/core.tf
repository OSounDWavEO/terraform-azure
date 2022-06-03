# Configure the Azure Provider
provider "azurerm" {
	subscription_id	= var.subscription_id
	features {}
}

module "core" {
	source	= "../modules/core_resources"

	subscription_id		= var.subscription_id
	resource_group_name	= "example-resource-group"
	prefix				= "dev-example"

	tags	= {
		Project		= "Example"
		Environment	= "Development"
	}
}