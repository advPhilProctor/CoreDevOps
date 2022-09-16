# Customer vNET, Subnet and NSG // Backup only
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.locShortCode}-${var.custShortCode}-01"
  location            = var.rg_location
  resource_group_name = var.rg_name
  address_space       = [var.cust_base_cidr_block]
  tags = local.tags
}
resource "azurerm_subnet" "sn" {
    name           = "sn-${var.locShortCode}-${var.custShortCode}-str-01"
    address_prefixes = local.cust_storage_sub
    resource_group_name = var.rg_name
    virtual_network_name = azurerm_virtual_network.vnet.name
    #security_group = (var.pep_required == 0 ? null : azurerm_network_security_group.nsg.id)
    enforce_private_link_endpoint_network_policies = false
  }

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.locShortCode}-${var.custShortCode}-str-01"
  location            = var.rg_location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "Storage-Access"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges     = ["443"]
    source_address_prefix      = local.white_list_ip[0]
    destination_address_prefix = "*"
  }
  tags = local.tags
}

resource "azurerm_subnet_network_security_group_association" "nsg-a" {
  subnet_id                 = azurerm_subnet.sn.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_private_dns_zone" "dns" {
  name                = "${var.locShortCode}${var.custShortCode}.blob.core.windows.net"
  resource_group_name = var.rg_name
  tags = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "nwl" {
  name                  = "nwl-${var.locShortCode}-${var.custShortCode}"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  tags = local.tags
}

resource "azurerm_private_endpoint" "pep" {
  name                = "pep-${var.locShortCode}-${var.custShortCode}-str-01"
  location            = var.rg_location
  resource_group_name = var.rg_name
  subnet_id           = azurerm_subnet.sn.id
  tags = local.tags

  private_service_connection {
    name                           = "psc-${var.locShortCode}-${var.custShortCode}-str-01"
    private_connection_resource_id = var.storage_account_id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

resource "azurerm_private_dns_a_record" "dns_a" {
  name                = "${var.locShortCode}-${var.custShortCode}-str-01"
  zone_name           = azurerm_private_dns_zone.dns.name
  resource_group_name = var.rg_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.pep.private_service_connection.0.private_ip_address]
  tags = local.tags
}