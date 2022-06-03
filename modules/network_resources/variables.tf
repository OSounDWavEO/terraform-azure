variable "resource_group" {
	type		= map
	description	= "Resource group data"
}

variable "prefix" {
	type		= string
	description	= "Resource prefix"
}

variable "az" {
	type		= list(string)
	description	= "list of Azure availability zones"
	default		= ["1", "2", "3"]
}

variable "internal_dns_resource_group" {
	type		= string
	description	= "Name of resource group of internal DNS"
}

variable "internal_root_domain" {
	type		= string
	description	= "Name of internal root domain"
}

variable "vnet_address_space" {
	type		= list
	description	= "IP range for dedicated virtual network"
}

variable "internal_root_domain" {
	type		= string
	description	= "Private DNS zone"
}

variable "enable_nat" {
	type		= bool
	description	= "Provision NAT server if true"
	default		= false
}

variable "tags" {
	type		= map(string)
	description	= "Tags"
}