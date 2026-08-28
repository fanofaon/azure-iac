variable "name" {
  description = "Nom du Resource Group Azure"
  type        = string
}

variable "location" {
  description = "Region Azure du Resource Group"
  type        = string
}

variable "tags" {
  description = "Tags appliques au Resource Group"
  type        = map(string)
  default     = {}
}
