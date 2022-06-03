module "example_network" {
	source	= "../modules/network_resources"

	resource_group		= module.core.resource_group

	tags	= {
		Project		= "Example"
		Environment	= "Development"
	}

	prefix				= "dev-example"
	vnet_address_space	= ["10.0.0.0/24"]

	internal_dns_resource_group	= "dns-rg"
	internal_root_domain		= "example.com"
}

module "example_server" {
	source	= "../modules/single_vm_resources"

	vm_username			= var.vm_username
	vm_pubkey			= var.vm_pubkey
	resource_group		= module.core.resource_group

	tags	= {
		Project		= "Example"
		Environment	= "Development"
	}

	prefix		= "dev-example"
	subnet_id	= module.example_network.subnet_ids["public_dmz"]

	internal_dns_resource_group	= "dns-rg"
	internal_root_domain		= "example.com"
}

output "vm_id" {
	value	= module.example_server.vm_id
}

output "vm_dns" {
	value	= module.example_server.vm_internal_dns
}