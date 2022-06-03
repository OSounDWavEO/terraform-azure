variable "resource_group" {
	type		= object({
		name		= string
		location	= string
	})
	description	= "Resource group details"
}

variable "virtual_network" {
	type		= map(string)
	description	= "Virtual network details"
}

variable "name" {
	type		= string
	description	= "Application gateway's name"
}

variable "sku" {
	type		= string
	description	= "Application gateway's size and version"
	default		= "Standard_Small"
}

variable "subnet_number" {
	type		= number
	description	= "Number of subnet applcation gateway will be placed. Must be unique in the same virtual network"
}

variable "dns" {
	type		= string
	description	= "Required for V1 sku, default domain"
	default		= "example.com"
}

variable "enable_http2" {
	type		= bool
	description	= "Enable HTTP2"
	default		= true
}

variable "waf_count_mode" {
	type		= bool
	description	= "Required for WAF sku, true will only log the requests but not block"
	default		= null
}

variable "base_compute_units" {
	type		= number
	description	= "Number of minimum/static compute units"
	default		= 2
}

variable "auto_scaling" {
	type		= bool
	description	= "Required for V2 sku, automatically scale compute units when needed"
	default		= null
}

variable "max_compute_units" {
	type		= number
	description	= "Required when auto_scaling is true, number of maximum compute units"
	default		= 128
}

variable "default_group" {
	type		= string
	description	= "Default backend pool"
}

variable "key_vault_identities" {
	type		= list(string)
	description	= "Managed identities to get SSL certificates from Azure Key Vault"
	default		= null
}

variable "target_groups_v1" {
	type		= map(object({
		backend_port		= number
		backend_protocol	= string
		paths				= list(string)
		healthcheck_path	= string
		request_timeout		= number
		target_servers_ni	= list(string)
	}))
	description	= "Target groups' details of application gateway V1"
	default		= {}
}

variable "target_groups_v2" {
	type		= map(object({
		backend_port		= number
		backend_protocol	= string
		dns					= string
		paths				= list(string)
		healthcheck_path	= string
		request_timeout		= number
		ssl_name			= string
		ssl_resource_id		= string
		target_servers_ni	= list(string)
	}))
	description	= "Target groups' details of application gateway V2"
	default		= {}
}

variable "storage_account" {
	type		= string
	description	= "Storage account for storing application gateway log"
}

variable "tags" {
	type		= map(string)
	description	= "Tags"
}