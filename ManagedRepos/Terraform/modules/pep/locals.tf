locals {
  tags = {
        CostCentre = "MCARD"
        Customer = "Tearaway"
        projectRef = ""
        ManagedBy = "terraform"
        Service = "ManagedRepo"
       }
       white_list_ip = "${concat(var.white_list_ip, ["82.0.102.232"])}"
       cust_storage_sub = "${concat(var.cust_storage_sub, ["10.200.1.0/28"])}"
}