
variable "vm_username" {
	type		= string
	description	= "Virtual machines log in username, put in terraform.tfvars"
}

variable "vm_pubkey" {
	type		= string
	description	= "Virtual machines log in public key, put in terraform.tfvars"
}

variable "resource_group" {
	type		= map(string)
	description	= "Resource group data"
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

variable "prefix" {
	type		= string
	description	= "Resources' prefix"
}

variable "subnet_id" {
	type		= string
	description	= "Subnet ID to place VM"
}

variable "vm_image" {
	type		= map(string)
	description	= "Virtual machine image server"
	default		= {
		publisher	= "OpenLogic"
		offer		= "CentOS"
		sku			= "7.7"
	}
}

variable "vm_size" {
	type		= string
	description	= "Virtual machine size of server"
	default		= "Standard_B2s"
}

variable "vm_storage" {
	type		= number
	description	= "Virtual machine storage of server"
	default		= 64
}

variable "tags" {
	type		= map(string)
	description	= "Resources' tags"
}