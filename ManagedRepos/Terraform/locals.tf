locals {
  resourceGroupName="rg-${var.locShortCode}-${local.custShortCode}-repo-01"
  custShortCode = "taw" //csc
  accountTier = "Standard" //Note: HYCU for Azure does not support premium storage accounts
  accessTier = "Cool" // Default set to Cool for backups (expect to libe for 30 days)
  replicationType = "LRS"
  tags = {
        CostCentre = "MCARD"
        Customer = "Tearaway"
        projectRef = ""
        ManagedBy = "terraform"
        Service = "ManagedRepo"
       }
  cust_base_cidr_block = "10.200.1.0/27" // 16 addresses
  cust_storage_sub = "${concat(var.cust_storage_sub, ["10.200.1.0/28"])}"
  white_list_ip = "${concat(var.white_list_ip, ["82.0.102.232"])}"

  }