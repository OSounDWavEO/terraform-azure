resource "azurerm_lb" "nat" {
	count	= var.enable_nat ? 1 : 0

	name				= "${var.prefix}-nat"
	resource_group_name	= var.resource_group["name"]
	location			= var.resource_group["location"]
	sku					= "Standard"

	frontend_ip_configuration {
		name					= "public"
		public_ip_address_id	= azurerm_public_ip.nat[0].id
	}

	tags	= merge(var.tags, {
		Name		= "${var.prefix}-nat-lb"
		Zone		= "Public"
	})
}

resource "azurerm_lb_backend_address_pool" "nat" {
	count	= var.enable_nat ? 1 : 0

	resource_group_name	= var.resource_group["name"]
	loadbalancer_id		= azurerm_lb.nat[0].id
	name				= "allvm"
}

resource "azurerm_lb_outbound_rule" "nat" {
	count	= var.enable_nat ? 1 : 0

	resource_group_name		= var.resource_group["name"]
	loadbalancer_id			= azurerm_lb.nat[0].id
	name					= "NAT"
	protocol				= "All"
	backend_address_pool_id	= azurerm_lb_backend_address_pool.nat[0].id

	frontend_ip_configuration {
		name	= "public"
	}
}