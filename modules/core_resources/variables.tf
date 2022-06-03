variable "subscription_id" {
	type		= string
	description	= "Subscription ID, put in terraform.tfvars"
}

variable "resource_group_name" {
	type		= string
	description	= "Name of resource group"
}

variable "resource_group_location" {
	type		= string
	description	= "Azure location of resource group"
	default		= "southeastasia"
}

variable "prefix" {
	type		= string
	description	= "Resources' prefix"
}

variable "tags" {
	type		= map(string)
	description	= "Tags"
}