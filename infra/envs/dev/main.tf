locals {
  prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = var.project_name
  }
}

module "resource_group" {
  source = "../../modules/resource_group"

  name     = "rg-${local.prefix}"
  location = var.location
  tags     = local.common_tags
}

module "network" {
  source = "../../modules/network"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  vnet_name     = "vnet-${local.prefix}"
  address_space = ["10.0.0.0/16"]

  subnet_name     = "snet-app"
  subnet_prefixes = ["10.0.1.0/24"]

  tags = local.common_tags
}

module "security" {
  source = "../../modules/security"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  nsg_name   = "nsg-${local.prefix}"
  subnet_id  = module.network.subnet_id
  admin_cidr = var.admin_cidr

  tags = local.common_tags
}

module "compute" {
  source = "../../modules/compute"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  subnet_id           = module.network.subnet_id

  vm_name        = "vm-${local.prefix}"
  vm_size        = var.vm_size
  admin_username = var.admin_username

  ssh_public_key = file(pathexpand(var.ssh_public_key_path))

  tags = local.common_tags
}
