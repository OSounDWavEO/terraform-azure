variable "vm_username" {
	type		= string
	description	= "Virtual machines log in username, put in terraform.tfvars"
}

variable "vm_pubkey" {
	type		= string
	description	= "Virtual machines log in public key, put in terraform.tfvars"
}

variable "prefix" {
	type		= string
	description	= "Resource prefix"
}

variable "resource_group" {
	type		= object({
		name		= string
		location	= string
	})
	description	= "Resource group details"
}

variable "nat_lb_pool" {
	type		= string
	description	= "NAT load balancer backend pool"
}

variable "az" {
	type		= list(string)
	description	= "list of Azure availability zones"
}

variable "internal_dns_resource_group" {
	type		= string
	description	= "Name of resource group of internal DNS"
}

variable "internal_root_domain" {
	type		= string
	description	= "Name of internal root domain"
}

variable "virtual_network" {
	type		= map(string)
	description	= "Virtual network"
}

variable "subnet_ids" {
	type		= map(string)
	description	= "Subnet IDs"
}

variable "separate_admin" {
	type		= bool
	description	= "True for provision dedicated admin server"
}

variable "separate_nfs" {
	type		= bool
	description	= "True for provision dedicated NFS server"
}

variable "vm_admin_az" {
	type		= string
	description	= "Availability zone which admin, NFS, NAT and primary Redis servers placed"
}

variable "vm_admin_size" {
	type		= string
	description	= "Virtual machine size of admin server"
}

variable "vm_admin_storage" {
	type		= number
	description	= "Virtual machine data storage of admin server"
}

variable "vm_app_image" {
	type		= map(string)
	description	= "Virtual machine image of admin and app servers"
}

variable "vm_app_count" {
	type		= number
	description	= "Number of virtual machine of application servers"
}

variable "vm_app_size" {
	type		= string
	description	= "Virtual machine size of application servers"
}

variable "vm_app_storage" {
	type		= number
	description	= "Virtual machine storage of application servers"
}

variable "vm_nfs_image" {
	type		= map(string)
	description	= "Virtual machine image of NFS server"
}

variable "vm_nfs_size" {
	type		= string
	description	= "Virtual machine size of NFS server"
}

variable "vm_nfs_storage" {
	type		= number
	description	= "Virtual machine storage of NFS server"
}

variable "vm_redis_image" {
	type		= map(string)
	description	= "Virtual machine image of Redis servers"
}

variable "vm_redis_count" {
	type		= number
	description = "Number of virtual machine of Redis servers"
}

variable "vm_redis_size" {
	type		= string
	description	= "Virtual machine size of Redis servers"
}

variable "vm_redis_storage" {
	type		= number
	description	= "Virtual machine storage of Redis servers"
}

variable "db_count" {
	type		= number
	description = "Number of database servers"
}

variable "db_engine_version" {
	type		= string
	description	= "Engine version of database servers"
}

variable "db_sku" {
	type		= string
	description = "SKU of database server (B-Basic, GP-General Purpose, MO-Memory Optimized)"
}

variable "db_primary_cpu" {
	type		= number
	description = "Number of CPU of primary database server"
}

variable "db_replica_cpu" {
	type		= number
	description	= "Number of CPU of replica database servers"
}

variable "db_storage" {
	type		= number
	description	= "Storage of database servers in MB"
}

variable "vm_backup" {
	type		= bool
	description	= "Enable VM backup on admin, app and NFS servers"
	default		= true
}

variable "tags" {
	type		= map(string)
	description	= "Tags"
}