resource "azurerm_recovery_services_vault" "backup_vault" {
	count	= var.vm_backup ? 1 : 0

	name				= "${var.prefix}-backup-vault"
	location			= var.resource_group["location"]
	resource_group_name	= var.resource_group["name"]
	sku					= "Standard"

	tags	= merge(var.tags, {
		Name		= "${var.prefix}-backup-vault"
		Zone		= "Private"
	})
}

resource "azurerm_backup_policy_vm" "vm_policy" {
	// initiate loop
	count	= var.vm_backup ? 1 : 0

	name				= "${var.prefix}-app"
	resource_group_name	= lower(var.resource_group["name"])
	recovery_vault_name	= azurerm_recovery_services_vault.backup_vault[0].name

	backup {
		frequency	= "Daily"
		time		= "20:00"
	}

	retention_daily {
		count	= 7
	}
}

resource "azurerm_backup_protected_vm" "admin" {
	// initiate loop
	count	= var.separate_admin && var.vm_backup ? 1 : 0

	resource_group_name	= lower(var.resource_group["name"])
	recovery_vault_name	= azurerm_recovery_services_vault.backup_vault[0].name
	source_vm_id		= azurerm_virtual_machine.admin[0].id
	backup_policy_id	= azurerm_backup_policy_vm.vm_policy[0].id
}

resource "azurerm_backup_protected_vm" "app" {
	// initiate loop
	count	= var.vm_backup ? var.vm_app_count : 0

	resource_group_name	= lower(var.resource_group["name"])
	recovery_vault_name	= azurerm_recovery_services_vault.backup_vault[0].name
	source_vm_id		= azurerm_virtual_machine.app[count.index].id
	backup_policy_id	= azurerm_backup_policy_vm.vm_policy[0].id
}

resource "azurerm_backup_protected_vm" "nfs" {
	// initiate loop
	count	= var.separate_nfs && var.vm_backup ? 1 : 0

	resource_group_name	= lower(var.resource_group["name"])
	recovery_vault_name	= azurerm_recovery_services_vault.backup_vault[0].name
	source_vm_id		= azurerm_virtual_machine.nfs[0].id
	backup_policy_id	= azurerm_backup_policy_vm.vm_policy[0].id
}