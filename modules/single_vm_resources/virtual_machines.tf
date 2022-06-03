resource "azurerm_network_interface" "single" {
	name							= var.prefix
	location						= var.resource_group["location"]
	resource_group_name				= var.resource_group["name"]
	internal_dns_name_label			= var.prefix
	enable_accelerated_networking	= false

	ip_configuration {
		name							= "primary"
		subnet_id						= var.subnet_id
		private_ip_address_allocation	= "dynamic"
		public_ip_address_id			= azurerm_public_ip.single.id
	}

	tags	= merge(var.tags, {
		Name		= "${var.prefix}-ni"
		Zone		= "Public"
	})
}

resource "azurerm_network_interface_security_group_association" "single" {
	network_interface_id		= azurerm_network_interface.single.id
	network_security_group_id	= azurerm_network_security_group.single.id
}

resource "azurerm_virtual_machine" "single" {
	name							= var.prefix
	resource_group_name				= var.resource_group["name"]
	location						= var.resource_group["location"]
	zones							= [random_shuffle.az.result[0]]
	network_interface_ids			= [azurerm_network_interface.single.id]
	vm_size							= var.vm_size
	delete_os_disk_on_termination	= true

	storage_image_reference {
		publisher	= data.azurerm_platform_image.single.publisher
		offer		= data.azurerm_platform_image.single.offer
		sku			= data.azurerm_platform_image.single.sku
		version		= data.azurerm_platform_image.single.version
	}

	storage_os_disk {
		name				= "${var.prefix}-os"
		create_option		= "FromImage"
		managed_disk_type	= "Premium_LRS"
		os_type				= "linux"
		disk_size_gb		= var.vm_storage
	}

	os_profile {
		computer_name	= var.prefix
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
		Name				= "${var.prefix}-vm"
		Zone				= "Public"
		Group				= var.prefix
		Size				= var.vm_size
	})

	lifecycle {
		ignore_changes	= [storage_image_reference]
	}
}