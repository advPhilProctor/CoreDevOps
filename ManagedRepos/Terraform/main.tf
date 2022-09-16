terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
  backend "azurerm" {
  resource_group_name = "rg-uks-adv-mgmt-01"
  storage_account_name = "ctl0storage"
  container_name = "tfstate"
  key = "global/service/managedRepo/twn/terraform.tfstate"
  }

  required_version = ">= 1.1.0"
}
provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  features {}
}

# Customer Resource Group
resource "azurerm_resource_group" "rg" {
  name     = local.resourceGroupName
  location = var.location
  tags = local.tags
}

# Cusotmer Storage Account
resource "azurerm_storage_account" "stracct" {
  name                     = "${var.locShortCode}${local.custShortCode}repo01"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = local.accountTier
  access_tier = local.accessTier
  account_replication_type = local.replicationType
  enable_https_traffic_only = true

  network_rules {
    default_action = "Deny"
    ip_rules = local.white_list_ip // Source Data IP (customer and Advatek)
  }
  tags = local.tags
}

output "storage_account_primary_connection_string" {
    value = azurerm_storage_account.stracct.primary_connection_string
    sensitive = true
}

output "storage_account_primary_access_key" {
    value = azurerm_storage_account.stracct.primary_access_key
    sensitive = true
  
}

# Customer backup repo container
resource "azurerm_storage_container" "strcont" {
  name                  = "${local.custShortCode}-repo-01"
  storage_account_name  = azurerm_storage_account.stracct.name
}

resource "azurerm_storage_management_policy" "strPol" {
    storage_account_id = azurerm_storage_account.stracct.id
    rule {
    name    = "Dehydrate-10-50-100"
    enabled = true
    filters {
      prefix_match = ["${azurerm_storage_container.strcont.name}/prefix1"] // To show all blobs starting with "prefix1", type: "mycontainer/prefix1"
      blob_types   = ["blockBlob"]
      match_blob_index_tag {
        name      = "tag1"
        operation = "=="
        value     = "val1"
      }
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 10
        tier_to_archive_after_days_since_modification_greater_than = 50
        delete_after_days_since_modification_greater_than          = 100
      }
    }
  }
}

resource "azurerm_storage_blob_inventory_policy" "inventory" {
  storage_account_id = azurerm_storage_account.stracct.id
  rules {
    name                   = "DailyUsage"
    storage_container_name = azurerm_storage_container.strcont.name
    format                 = "Csv"
    schedule               = "Daily"
    scope                  = "Container"
    schema_fields = [
      "Name",
      "Last-Modified",
    ]
  }
}

module "pep" {
  source = "./modules/pep"

  count = var.pep_required == true ? 1 : 0

  locShortCode = var.locShortCode
  custShortCode = local.custShortCode
  rg_location = azurerm_resource_group.rg.location
  rg_name = azurerm_resource_group.rg.name
  cust_base_cidr_block = local.cust_base_cidr_block
  #cust_storage_sub = local.cust_storage_sub
  pep_required = var.pep_required
  storage_account_id = azurerm_storage_account.stracct.id
}