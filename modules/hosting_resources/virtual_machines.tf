resource "azurerm_network_interface" "admin" {
	// initiate loop
	count	= var.separate_admin ? 1 : 0

	name							= "${var.prefix}-admin"
	location						= var.resource_group["location"]
	resource_group_name				= var.resource_group["name"]
	internal_dns_name_label			= "${var.prefix}-admin"
	enable_accelerated_networking	= false

	ip_configuration {
		name							= "primary"
		subnet_id						= var.subnet_ids["private_app"]
		private_ip_address_allocation	= "dynamic"
	}

	tags	= merge(var.tags, {
		Name		= "${var.prefix}-admin-ni"
		Zone		= "Private"
	})
}

resource "azurerm_network_interface_backend_address_pool_association" "admin" {
	// initiate loop
	count	= var.separate_admin ? 1 : 0

	network_interface_id	= azurerm_network_interface.admin[count.index].id
	ip_configuration_name	= "primary"
	backend_address_pool_id	= var.nat_lb_pool

	depends_on	= [var.nat_lb_pool]
}

resource "azurerm_network_interface" "app" {
	// initiate loop
	count	= var.vm_app_count

	name							= "${var.prefix}-${!var.separate_admin && count.index == 0 ? "admin-" : ""}app-${format("%02d", count.index)}"
	location						= var.resource_group["location"]
	resource_group_name				= var.resource_group["name"]
	internal_dns_name_label			= "${var.prefix}-app-${format("%02d", count.index)}"
	enable_accelerated_networking	= substr(var.vm_app_size, 0, 10) == "Standard_B" ? false : true

	ip_configuration {
		name							= "primary"
		subnet_id						= var.subnet_ids["private_app"]
		private_ip_address_allocation	= "dynamic"
	}

	tags	= merge(var.tags, {
		Name		= "${var.prefix}-${!var.separate_admin && count.index == 0 ? "admin-" : ""}app-${format("%02d", count.index)}-ni"
		Zone		= "Private"
	})
}

resource "azurerm_network_interface_backend_address_pool_association" "app" {
	// initiate loop
	count	= var.vm_app_count

	network_interface_id	= azurerm_network_interface.app[count.index].id
	ip_configuration_name	= "primary"
	backend_address_pool_id	= var.nat_lb_pool

	depends_on	= [var.nat_lb_pool]
}

resource "azurerm_network_interface" "file" {
	// initiate loop
	count	= var.separate_file ? 1 : 0

	name							= "${var.prefix}-file"
	location						= var.resource_group["location"]
	resource_group_name				= var.resource_group["name"]
	internal_dns_name_label			= "${var.prefix}-file"
	enable_accelerated_networking	= substr(var.vm_file_size, 0, 10) == "Standard_B" ? false : true

	ip_configuration {
		name							= "primary"
		subnet_id						= var.subnet_ids["private_app"]
		private_ip_address_allocation	= "dynamic"
	}

	tags	= merge(var.tags, {
		Name		= "${var.prefix}-file-ni"
		Zone		= "Private"
	})
}

resource "azurerm_network_interface_backend_address_pool_association" "file" {
	// initiate loop
	count	= var.separate_file ? 1 : 0

	network_interface_id	= azurerm_network_interface.file[count.index].id
	ip_configuration_name	= "primary"
	backend_address_pool_id	= var.nat_lb_pool

	depends_on	= [var.nat_lb_pool]
}

resource "azurerm_network_interface" "redis" {
	// initiate loop
	count = var.vm_redis_count

	name					= "${var.prefix}-redis-${format("%02d", count.index)}"
	location				= var.resource_group["location"]
	resource_group_name		= var.resource_group["name"]
	internal_dns_name_label	= "${var.prefix}-redis-${format("%02d", count.index)}"

	ip_configuration {
		name							= "primary"
		subnet_id						= var.subnet_ids["private_data"]
		private_ip_address_allocation	= "dynamic"
	}

	tags	= merge(var.tags, {
		Name		= "${var.prefix}-redis-${format("%02d", count.index)}-ni"
		Zone		= "Private"
	})
}

resource "azurerm_network_interface_backend_address_pool_association" "redis" {
	// initiate loop
	count	= var.vm_redis_count

	network_interface_id	= azurerm_network_interface.redis[count.index].id
	ip_configuration_name	= "primary"
	backend_address_pool_id	= var.nat_lb_pool

	depends_on	= [var.nat_lb_pool]
}

resource "azurerm_virtual_machine" "admin" {
	// initiate loop
	count	= var.separate_admin ? 1 : 0

	name							= "${var.prefix}-admin"
	resource_group_name				= var.resource_group["name"]
	location						= var.resource_group["location"]
	zones							= [var.az[var.vm_admin_az]]
	network_interface_ids			= [azurerm_network_interface.admin[0].id]
	vm_size							= var.vm_admin_size
	delete_os_disk_on_termination	= true

	storage_image_reference {
		publisher	= data.azurerm_platform_image.app.publisher
		offer		= data.azurerm_platform_image.app.offer
		sku			= data.azurerm_platform_image.app.sku
		version		= data.azurerm_platform_image.app.version
	}

	storage_os_disk {
		name				= "${var.prefix}-admin-os"
		create_option		= "FromImage"
		managed_disk_type	= "Premium_LRS"
		os_type				= "linux"
		disk_size_gb		= var.vm_admin_storage
	}

	os_profile {
		computer_name	= "${var.prefix}-admin"
		admin_username	= var.vm_username
	}

	os_profile_linux_config {
		disable_password_authentication	= true

		ssh_keys {
			path		= "/home/${var.vm_username}/.ssh/authorized_keys"
			key_data	= var.vm_pubkey
		}
	}

	tags	= merge(var.tags, {
		Name				= "${var.prefix}-admin-vm"
		Zone				= "Private"
		Group				= "${var.prefix}-admin"
		Size				= var.vm_admin_size
	})

	lifecycle {
		ignore_changes	= [storage_image_reference]
	}
}

resource "azurerm_virtual_machine" "app" {
	// initiate loop
	count	= var.vm_app_count

	name							= "${var.prefix}-${!var.separate_admin && count.index == 0 ? "admin-" : ""}app-${format("%02d", count.index)}"
	resource_group_name				= var.resource_group["name"]
	location						= var.resource_group["location"]
	zones							= [element(var.az, count.index + (var.separate_admin ? var.vm_admin_az + 1 : 0))]
	network_interface_ids			= [azurerm_network_interface.app[count.index].id]
	vm_size							= var.vm_app_size
	delete_os_disk_on_termination	= true

	storage_image_reference {
		publisher	= data.azurerm_platform_image.app.publisher
		offer		= data.azurerm_platform_image.app.offer
		sku			= data.azurerm_platform_image.app.sku
		version		= data.azurerm_platform_image.app.version
	}

	storage_os_disk {
		name				= "${var.prefix}-${!var.separate_admin && count.index == 0 ? "admin-" : ""}app-${format("%02d", count.index)}-os"
		create_option		= "FromImage"
		managed_disk_type	= "Premium_LRS"
		os_type				= "linux"
		disk_size_gb		= var.vm_app_storage
	}

	os_profile {
		computer_name	= "${var.prefix}-${!var.separate_admin && count.index == 0 ? "admin-" : ""}app-${format("%02d", count.index)}"
		admin_username	= var.vm_username
	}

	os_profile_linux_config {
		disable_password_authentication	= true

		ssh_keys {
			path		= "/home/${var.vm_username}/.ssh/authorized_keys"
			key_data	= var.vm_pubkey
		}
	}

	tags	= merge(var.tags, {
		Name				= "${var.prefix}-${!var.separate_admin && count.index == 0 ? "admin-" : ""}app-${format("%02d", count.index)}-vm"
		Zone				= "Private"
		Group				= "${var.prefix}-app"
		Size				= var.vm_app_size
	})

	lifecycle {
		ignore_changes	= [storage_image_reference]
	}
}

resource "azurerm_virtual_machine" "file" {
	// initiate loop
	count	= var.separate_file ? 1 : 0

	name							= "${var.prefix}-file"
	resource_group_name				= var.resource_group["name"]
	location						= var.resource_group["location"]
	zones							= [var.az[var.separate_admin ? var.vm_admin_az : 0]]
	network_interface_ids			= [azurerm_network_interface.file[0].id]
	vm_size							= var.vm_file_size
	delete_os_disk_on_termination	= true

	storage_image_reference {
		publisher	= data.azurerm_platform_image.file.publisher
		offer		= data.azurerm_platform_image.file.offer
		sku			= data.azurerm_platform_image.file.sku
		version		= data.azurerm_platform_image.file.version
	}

	storage_os_disk {
		name				= "${var.prefix}-file-os"
		create_option		= "FromImage"
		managed_disk_type	= "Premium_LRS"
		os_type				= "linux"
		disk_size_gb		= var.vm_file_storage
	}

	os_profile {
		computer_name	= "${var.prefix}-file"
		admin_username	= var.vm_username
	}

	os_profile_linux_config {
		disable_password_authentication	= true

		ssh_keys {
			path		= "/home/${var.vm_username}/.ssh/authorized_keys"
			key_data	= var.vm_pubkey
		}
	}

	tags	= merge(var.tags, {
		Name				= "${var.prefix}-file-vm"
		Zone				= "Private"
		Group				= "${var.prefix}-file"
		Size				= var.vm_file_size
	})

	lifecycle {
		ignore_changes	= [storage_image_reference]
	}
}

resource "azurerm_virtual_machine" "redis" {
	// initiate loop
	count	= var.vm_redis_count

	name							= "${var.prefix}-redis-${format("%02d", count.index)}"
	resource_group_name				= var.resource_group["name"]
	location						= var.resource_group["location"]
	zones							= [element(var.az, count.index + (var.separate_admin ? var.vm_admin_az : 0))]
	network_interface_ids			= [azurerm_network_interface.redis[count.index].id]
	vm_size							 = var.vm_redis_size
	delete_os_disk_on_termination	= true

	storage_image_reference {
		publisher	= data.azurerm_platform_image.redis.publisher
		offer		= data.azurerm_platform_image.redis.offer
		sku			= data.azurerm_platform_image.redis.sku
		version		= data.azurerm_platform_image.redis.version
	}

	storage_os_disk {
		name				= "${var.prefix}-redis-${format("%02d", count.index)}-os"
		create_option		= "FromImage"
		managed_disk_type	= "Standard_LRS"
		os_type				= "linux"
		disk_size_gb		= "32"
	}

	os_profile {
		computer_name	= "${var.prefix}-redis-${format("%02d", count.index)}"
		admin_username	= var.vm_username
	}

	os_profile_linux_config {
		disable_password_authentication	= true

		ssh_keys {
			path		= "/home/${var.vm_username}/.ssh/authorized_keys"
			key_data	= var.vm_pubkey
		}
	}

	tags	= merge(var.tags, {
		Name				= "${var.prefix}-redis-${format("%02d", count.index)}-vm"
		Zone				= "Private"
		Group				= "${var.prefix}-redis"
		Size				= var.vm_redis_size
	})

	lifecycle {
		ignore_changes	= [storage_image_reference]
	}
}