variable "tenant_id" {
    type = string
    default = "acffc636-5a80-4955-a206-086cec24fded"
}

variable "subscription_id" {
    type = string
    default = "81b414ca-cfbf-411c-8f04-8401250500cc" // Advatek Storage Repo
}

variable "location" {
  type = string
  default = "uksouth"
  
}

variable "locShortCode" { //lsc
    type = string
    default = "uks"
  
}

variable "pep_required" {
  type = bool
  description = "Creates vNET, Subnet and associated Private End Point if true"
}

variable "white_list_ip" {
  type = list(string)
  default = []
  
}

variable "cust_storage_sub" {
    type = list(string)
    default = []
  
}