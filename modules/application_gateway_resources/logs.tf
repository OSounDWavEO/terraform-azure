resource "azurerm_monitor_diagnostic_setting" "app_gateway_v1" {
	count	= length(regexall("v2", var.sku)) > 0 ? 0 : 1

	name				= "${var.name}-app-gateway"
	target_resource_id	= azurerm_application_gateway.app_gateway_v1[0].id
	storage_account_id	= var.storage_account

	log {
		category = "ApplicationGatewayAccessLog"

		retention_policy {
			enabled	= true
			days	= 0
		}
	}

	log {
		category = "ApplicationGatewayFirewallLog"

		retention_policy {
			enabled	= true
			days	= 90
		}
	}

	log {
		category	= "ApplicationGatewayPerformanceLog"
		enabled		= false

		retention_policy {
			days	= 0
			enabled	= false
		}
	}

	metric {
		category	= "AllMetrics"
		enabled		= false

		retention_policy {
			days	= 0
			enabled	= false
		}
	}
}

resource "azurerm_monitor_diagnostic_setting" "app_gateway_v2" {
	count	= length(regexall("v2", var.sku)) > 0 ? 1 : 0

	name				= "${var.name}-app-gateway"
	target_resource_id	= azurerm_application_gateway.app_gateway_v2[0].id
	storage_account_id	= var.storage_account

	log {
		category	= "ApplicationGatewayAccessLog"

		retention_policy {
			enabled	= true
			days	= 0
		}
	}

	log {
		category	= "ApplicationGatewayFirewallLog"

		retention_policy {
			enabled	= true
			days	= 90
		}
	}

	log {
		category	= "ApplicationGatewayPerformanceLog"
		enabled		= false

		retention_policy {
			days	= 0
			enabled	= false
		}
	}

	metric {
		category	= "AllMetrics"
		enabled		= false

		retention_policy {
			days	= 0
			enabled	= false
		}
	}
}