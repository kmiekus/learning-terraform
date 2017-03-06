/*
choco install terraform -y
choco install GraphViz -y
add GraphViz bin to PATH
environment_variables.cmd
*/

# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

# Create a resource group
resource "azurerm_resource_group" "dcosrgroup" {
  name     = "irdacs0001rg"
  location = "North Europe"
}

#DCOS container service

resource "azurerm_container_service" "DCOS" {
  name                   = "containerservice-${azurerm_resource_group.dcosrgroup.name}"
  location               = "${azurerm_resource_group.dcosrgroup.location}"
  resource_group_name    = "${azurerm_resource_group.dcosrgroup.name}"
  orchestration_platform = "DCOS"

  master_profile {
    count      = "${var.masterProfileCount}"
    dns_prefix = "${var.dnsNamePrefix}mgmt"
  }

  linux_profile {
    admin_username = "${var.linuxAdminUsername}"

    ssh_key {
      key_data = "ssh-rsa  ${var.sshRSAPublicKey}"
    }
  }

  agent_pool_profile {
    name       = "agentpools"
    count      = "${var.agentCount}"
    dns_prefix = "${var.dnsNamePrefix}agents"

    #fqdn       = "you.demo.com"
    vm_size = "${var.agentVMSize}"
  }

  diagnostics_profile {
    enabled = false
  }

  tags {}
}

/*output "masterFQDN" {
  value = "${azurerm_container_service.DCOS.masterProfile.fqdn}"
}

output "sshMaster0" {
  value = "ssh ${var.linuxAdminUsername}@${azurerm_container_service.DCOS.masterProfile.fqdn}"
}

output "agentFQDN" {
  value = "${azurerm_container_service.DCOS.agent_pool_profile.0.fqdn}"
}*/

