module "template" {
	source	= "../"

	vm_username	= var.vm_username
	vm_pubkey	= var.vm_pubkey

	resource_group	= var.resource_group
	virtual_network	= var.virtual_network
	subnet_ids		= var.subnet_ids
	nat_lb_pool		= var.nat_lb_pool
	
	internal_dns_resource_group = var.internal_dns_resource_group
	internal_root_domain 		= var.internal_root_domain

	prefix	= var.prefix

	az	= var.az

	separate_admin	= var.separate_admin
	separate_nfs	= var.separate_nfs

	vm_admin_az			= var.vm_admin_az
	vm_admin_size		= var.vm_admin_size
	vm_admin_storage	= var.vm_admin_storage

	vm_app_image	= var.vm_app_image
	vm_app_count	= var.vm_app_count
	vm_app_size		= var.vm_app_size
	vm_app_storage	= var.vm_app_storage

	vm_nfs_image	= var.vm_nfs_image
	vm_nfs_size		= var.vm_nfs_size
	vm_nfs_storage	= var.vm_nfs_storage

	vm_redis_image		= var.vm_redis_image
	vm_redis_count		= var.vm_redis_count
	vm_redis_size		= var.vm_redis_size
	vm_redis_storage	= var.vm_redis_storage

	db_count			= var.db_count
	db_engine_version	= var.db_engine_version
	db_sku				= var.db_sku
	db_primary_cpu		= var.db_primary_cpu
	db_replica_cpu		= var.db_replica_cpu
	db_storage			= var.db_storage

	vm_backup	= var.vm_backup

	tags	= var.tags
}