module "example_network" {
	source	= "../modules/network_resources"

	resource_group	= module.core.resource_group

	prefix				= "prod-example"
	vnet_address_space	= ["10.0.0.0/24"]
	enable_nat			= true

	internal_dns_resource_group	= "dns-rg"
	internal_root_domain		= "example.com"

	tags	= {
		Project		= "Example"
		Environment	= "Production"
	}
}

module "example_hosting" {
	source	= "../modules/hosting_resources/small"

	resource_group	= module.core.resource_group
	virtual_network	= module.example_network.virtual_network
	subnet_ids		= module.example_network.subnet_ids
	nat_lb_pool		= module.example_network.nat_lb_pool

	vm_username	= var.vm_username
	vm_pubkey	= var.vm_pubkey
	prefix		= "prod-example"

	internal_dns_resource_group	= "dns-rg"
	internal_root_domain		= "example.com"

	tags	= {
		Project		= "Example"
		Environment	= "Production"
	}
}

module "example_app_gateway" {
	source	= "../modules/application_gateway_resources"

	resource_group	= module.core.resource_group
	virtual_network	= module.example_network.virtual_network
	storage_account	= module.example_network.storage_account

	name				= "prod-example"
	sku					= "Standard_Small"
	dns					= "www.example.com"
	subnet_number		= 0
	base_compute_units	= 2
	default_group		= "app"

	target_groups_v1	= {
		nfs	= {
			backend_port		= 80
			backend_protocol	= "http"
			paths				= ["/media*"]
			healthcheck_path	= "/"
			request_timeout		= 60
			target_servers_ni	= module.example_hosting.vm_nfs_ni
		}
		admin	= {
			backend_port		= 80
			backend_protocol	= "http"
			paths				= ["/admin*"]
			healthcheck_path	= "/admin"
			request_timeout		= 60
			target_servers_ni	= module.example_hosting.vm_admin_ni
		}
		app	= {
			backend_port		= 80
			backend_protocol	= "http"
			paths				= null
			healthcheck_path	= "/"
			request_timeout		= 60
			target_servers_ni	= module.example_hosting.vm_app_ni
		}
	}

	tags	= {
		Project		= "Example"
		Environment	= "Production"
	}
}

output "vm_admin_internal_dns" {
	value	= module.example_hosting.vm_admin_internal_dns
}

output "vm_app_internal_dns" {
	value	= module.example_hosting.vm_app_internal_dns
}

output "vm_nfs_internal_dns" {
	value	= module.example_hosting.vm_nfs_internal_dns
}

output "vm_redis_internal_dns" {
	value	= module.example_hosting.vm_redis_internal_dns
}