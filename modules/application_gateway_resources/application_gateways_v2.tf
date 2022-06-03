resource "azurerm_public_ip" "app_gateway_v2" {
	count	= signum(length(regexall("v2", var.sku)))

	name				= "${var.name}-app-gateway"
	resource_group_name	= var.resource_group["name"]
	location			= var.resource_group["location"]
	allocation_method	= "Static"
	sku					= "Standard"
	domain_name_label	= var.name

	tags	= merge(var.tags, {
		Name	= "${var.name}-app-gateway-public-ip"
		Zone	= "Public"
	})
}

resource "azurerm_application_gateway" "app_gateway_v2" {
	count	= signum(length(regexall("v2", var.sku)))

	name				= var.name
	resource_group_name	= var.resource_group["name"]
	location			= var.resource_group["location"]

	enable_http2	= var.enable_http2

	ssl_policy {
		policy_type				= "Custom"
		min_protocol_version	= "TLSv1_2"
		cipher_suites			= [
			"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
			"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
			"TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA",
			"TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256",
			"TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384",
			"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
			"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
			"TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA"
		]
	}

	sku {
		name		= var.sku
		tier		= length(regexall("v2", var.sku)) > 0 ? var.sku : split("_", var.sku)[0]
		capacity	= var.auto_scaling ? null : var.base_compute_units
	}

	dynamic "autoscale_configuration" {
		for_each	= var.auto_scaling ? {1 = 1} : {}

		content {
			min_capacity	= var.base_compute_units
			max_capacity	= var.max_compute_units
		}
	}

	gateway_ip_configuration {
		name		= azurerm_subnet.app_gateway.name
		subnet_id	= azurerm_subnet.app_gateway.id
	}

	frontend_ip_configuration {
		name					= "public"
		public_ip_address_id	= azurerm_public_ip.app_gateway_v2[0].id
	}

	frontend_port {
		name	= "http-80"
		port	= 80
	}

	frontend_port {
		name	= "https-443"
		port	= 443
	}

	dynamic "backend_address_pool" {
		for_each	= var.target_groups_v2

		content {
			name	= backend_address_pool.key
		}
	}

	dynamic "probe" {
		for_each	= var.target_groups_v2

		content {
			name				= "${probe.key}-${probe.value["backend_protocol"]}-${probe.value["backend_port"]}"
			protocol			= "Http"
			host				= probe.value["dns"] == null ? var.target_groups_v2[var.default_group]["dns"] : probe.value["dns"]
			path				= probe.value["healthcheck_path"]
			interval			= 30
			timeout				= 25
			unhealthy_threshold	= 3
		}
	}

	dynamic "backend_http_settings" {
		for_each	= var.target_groups_v2

		content {
			name					= "${backend_http_settings.key}-${backend_http_settings.value["backend_protocol"]}-${backend_http_settings.value["backend_port"]}"
			protocol				= title(backend_http_settings.value["backend_protocol"])
			port					= backend_http_settings.value["backend_port"]
			cookie_based_affinity	= "Disabled"
			request_timeout			= backend_http_settings.value["request_timeout"]
			probe_name				= "${backend_http_settings.key}-${backend_http_settings.value["backend_protocol"]}-${backend_http_settings.value["backend_port"]}"

			connection_draining {
				enabled				= true
				drain_timeout_sec	= 10
			}
		}
	}

	dynamic "http_listener" {
		for_each	= {for tg_key, tg_value in var.target_groups_v2 : tg_key => tg_value if tg_value["dns"] != null && tg_key != var.default_group}

		content {
			name							= "https-443-${http_listener.key}"
			frontend_ip_configuration_name	= "public"
			frontend_port_name				= "https-443"
			protocol						= "Https"
			host_name						= http_listener.value["dns"]
			ssl_certificate_name			= http_listener.value["ssl_name"] == null ? var.target_groups_v2[var.default_group]["ssl_name"] : http_listener.value["ssl_name"]
		}
	}

	http_listener {
		name							= "https-443"
		frontend_ip_configuration_name	= "public"
		frontend_port_name				= "https-443"
		protocol						= "Https"
		ssl_certificate_name			= var.target_groups_v2[var.default_group]["ssl_name"]
	}

	http_listener {
		name							= "http-80"
		frontend_ip_configuration_name	= "public"
		frontend_port_name				= "http-80"
		protocol						= "Http"
	}

	identity {
		identity_ids	= var.key_vault_identities
	}

	ssl_certificate {
		name				= var.target_groups_v2[var.default_group]["ssl_name"]
		key_vault_secret_id	= var.target_groups_v2[var.default_group]["ssl_resource_id"]
	}

	dynamic "ssl_certificate" {
		for_each	= {for tg_key, tg_value in var.target_groups_v2 : tg_key => tg_value if tg_value["ssl_name"] != null && tg_key != var.default_group}

		content {
			name				= ssl_certificate.value["ssl_name"]
			key_vault_secret_id	= ssl_certificate.value["ssl_resource_id"]
		}
	}

	request_routing_rule {
		name							= "http-80"
		rule_type						= "Basic"
		http_listener_name				= "http-80"
		redirect_configuration_name 	= "http-80-to-https-443"
	}

	redirect_configuration {
		name					= "http-80-to-https-443"
		redirect_type			= "Permanent"
		target_listener_name	= "https-443"
		include_path			= true
		include_query_string	= true
	}

	dynamic "request_routing_rule" {
		for_each	= {for tg_key, tg_value in var.target_groups_v2 : tg_key => tg_value if tg_value["dns"] != null && tg_key != var.default_group}

		content {
			name						= "https-443-${request_routing_rule.key}"
			rule_type					= "Basic"
			http_listener_name			= "https-443-${request_routing_rule.key}"
			backend_address_pool_name	= request_routing_rule.key
			backend_http_settings_name	= "${request_routing_rule.key}-${request_routing_rule.value["backend_protocol"]}-${request_routing_rule.value["backend_port"]}"
		}
	}

	dynamic "request_routing_rule" {
		for_each	= length({for tg_key, tg_value in var.target_groups_v2 : tg_key => tg_value if tg_value["paths"] != null && tg_key != var.default_group}) == 0 ? {1 = 1} : {}

		content {
			name						= "https-443"
			rule_type					= "Basic"
			http_listener_name			= "https-443"
			backend_address_pool_name	= var.default_group
			backend_http_settings_name	= "${var.default_group}-${var.target_groups_v2[var.default_group]["backend_protocol"]}-${var.target_groups_v2[var.default_group]["backend_port"]}"
		}
	}

	dynamic "request_routing_rule" {
		for_each	= length({for tg_key, tg_value in var.target_groups_v2 : tg_key => tg_value if tg_value["paths"] != null && tg_key != var.default_group}) == 0 ? {} : {1 = 1}

		content {
			name						= "https-443"
			rule_type					= "PathBasedRouting"
			http_listener_name			= "https-443"
			url_path_map_name 			= "https-443"
		}
	}

	dynamic "url_path_map" {
		for_each	= length({for tg_key, tg_value in var.target_groups_v2 : tg_key => tg_value if tg_value["paths"] != null && tg_key != var.default_group}) > 0 ? {1 = 1} : {}

		content {
			name								= "https-443"
			default_backend_address_pool_name	= var.default_group
			default_backend_http_settings_name	= "${var.default_group}-${var.target_groups_v2[var.default_group]["backend_protocol"]}-${var.target_groups_v2[var.default_group]["backend_port"]}"

			dynamic "path_rule" {
				for_each	= {for tg_key, tg_value in var.target_groups_v2 : tg_key => tg_value if tg_value["paths"] != null && tg_key != var.default_group}

				content {
					name						= path_rule.key
					paths						= path_rule.value["paths"]
					backend_address_pool_name	= path_rule.key
					backend_http_settings_name	= "${path_rule.key}-${path_rule.value["backend_protocol"]}-${path_rule.value["backend_port"]}"
				}
			}
		}
	}

	dynamic "waf_configuration" {
		for_each	= length(regexall("WAF", var.sku)) > 0 ? {1 = 1} : {}

		content {
			enabled				= true
			firewall_mode 		= var.waf_count_mode ? "Detection" : "Prevention"
			rule_set_type		= "OWASP"
			rule_set_version	= "3.1"
		}
	}

	tags	= merge(var.tags, {
		Name	= "${var.name}-app-gateway"
		Zone	= "Public"
	})

	lifecycle {
		ignore_changes	= [
			identity
		]
	}
}

locals {
	target_groups_matching_v2	= flatten([for target_group, params in var.target_groups_v2 :
		[for ni in params["target_servers_ni"] :
			{
				backend_pool		= matchkeys(azurerm_application_gateway.app_gateway_v2[0].backend_address_pool[*].id, azurerm_application_gateway.app_gateway_v2[0].backend_address_pool[*].name, [target_group])[0]
				network_interface	= ni
			}]
	])
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "target_servers_v2" {
	count	= length(local.target_groups_matching_v2)

	network_interface_id	= local.target_groups_matching_v2[count.index]["network_interface"]
	ip_configuration_name	= "primary"
	backend_address_pool_id	= local.target_groups_matching_v2[count.index]["backend_pool"]
}