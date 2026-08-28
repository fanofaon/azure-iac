# Infrastructure Terraform Azure

Ce répertoire contient l'infrastructure Azure gérée avec Terraform.

## Structure

- `envs/dev` : configuration de l'environnement de développement
- `modules/resource_group` : groupes de ressources Azure
- `modules/network` : réseau virtuel et sous-réseaux
- `modules/security` : règles de sécurité réseau
- `modules/compute` : machines virtuelles

Les fichiers `*.tfvars` contenant des valeurs locales ou sensibles ne doivent pas être versionnés.
