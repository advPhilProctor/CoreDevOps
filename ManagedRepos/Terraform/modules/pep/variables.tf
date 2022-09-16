variable "location" {
  type = string
  default = "uksouth"
  
}

variable "locShortCode" { //lsc
    type = string
    default = "uks"
  
}

variable "custShortCode" {
  type = string
}

variable "cust_storage_sub" {
    type = list(string)
    default = []
  
}
variable "cust_base_cidr_block" {
    type = string
  
}

variable "rg_location" {
    type = string
  
}

variable "rg_name" {
    type = string
  
}

variable "storage_account_id" {
    type = string
  
}

variable "pep_required" {
    type = bool
  
}

variable "white_list_ip" {
  type = list(string)
  default = []
  
}