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
	description	= "Resource group details"
}

variable "prefix" {
	type		= string
	description	= "Resource prefix"
}

variable "nat_lb_pool" {
	type		= string
	description	= "NAT load balancer backend pool"
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

variable "virtual_network" {
	type		= map(string)
	description	= "Virtual network"
}

variable "subnet_ids" {
	type		= map(string)
	description	= "Subnet IDs"
}

variable "separate_admin" {
	type		= string
	description	= "True for provision dedicated admin server"
	default		= false
}

variable "separate_nfs" {
	type		= bool
	description	= "True for provision dedicated NFS server"
	default		= true
}

variable "vm_admin_az" {
	type		= string
	description	= "Availability zone which admin, NFS, NAT and primary Redis servers placed"
	default		= "0"
}

variable "vm_admin_size" {
	type		= string
	description	= "Virtual machine size of admin server"
	default		= "Standard_D2s_V3"
}

variable "vm_admin_storage" {
	type		= number
	description	= "Virtual machine data storage of admin server"
	default		= 32
}

variable "vm_app_image" {
	type		= map(string)
	description	= "Virtual machine image of admin and app servers"
	default		= {
		publisher	= "OpenLogic"
		offer		= "CentOS"
		sku			= "7.7"
	}
}

variable "vm_app_count" {
	type		= number
	description	= "number of virtual machine of application servers"
	default		= 2
}

variable "vm_app_size" {
	type		= string
	description	= "Virtual machine size of application servers"
	default		= "Standard_F2s_V2"
}

variable "vm_app_storage" {
	type		= string
	description	= "Virtual machine storage of application servers"
	default		= 32
}

variable "vm_nfs_image" {
	type		= map(string)
	description	= "Virtual machine image of NFS server"
	default		= {
		publisher	= "OpenLogic"
		offer		= "CentOS"
		sku			= "7.7"
	}
}

variable "vm_nfs_size" {
	type		= string
	description	= "Virtual machine size of NFS server"
	default		= "Standard_B1ms"
}

variable "vm_nfs_storage" {
	type		= string
	description	= "Virtual machine storage of NFS server"
	default		= 128
}

variable "vm_redis_image" {
	type		= map(string)
	description	= "Virtual machine image of Redis servers"
	default		= {
		publisher	= "OpenLogic"
		offer		= "CentOS"
		sku			= "7.7"
	}
}

variable "vm_redis_count" {
	type 		= number
	description	= "number of virtual machine of Redis servers"
	default		= 1
}

variable "vm_redis_size" {
	type		= string
	description	= "Virtual machine size of Redis servers"
	default		= "Standard_B1ms"
}

variable "vm_redis_storage" {
	type		= number
	description	= "Virtual machine storage of Redis servers"
	default		= 32
}

variable "db_count" {
	type		= number
	description	= "Number of database servers"
	default		= 1
}

variable "db_engine_version" {
	type		= string
	description	= "Engine version of database servers"
	default		= "5.7"
}

variable "db_sku" {
	type		= string
	description = "SKU of database server (B-Basic, GP-General Purpose, MO-Memory Optimized)"
	default		= "GP"
}

variable "db_primary_cpu" {
	type		= number
	description	= "Number of CPU of primary database server"
	default		= 2
}

variable "db_replica_cpu" {
	type		= number
	description	= "Number of CPU of replica database servers"
	default		= 2
}

variable "db_storage" {
	type		= string
	description	= "Storage of database servers in MB"
	default		= 102400
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