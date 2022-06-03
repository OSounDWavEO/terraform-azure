variable "subscription_id" {
  type			= string
  description	= "Subscription ID, put in terraform.tfvars"
}

variable "vm_username" {
  type			= string
  description	= "Virtual machines log in username, put in terraform.tfvars"
}

variable "vm_pubkey" {
	type		= string
	description	= "Virtual machines log in public key, put in terraform.tfvars"
}

variable "azure_location" {
	type		= string
	description	= "Azure location"
	default		= "Southeast Asia"
}