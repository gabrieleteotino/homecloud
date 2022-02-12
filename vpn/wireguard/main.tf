locals {
  region         = "blr1"
  wg_server_net  = "192.168.175.0/24"
  wg_server_port = 51820
}

# Create ssh keypair
# Docs https://github.com/hashicorp/terraform-provider-tls/blob/main/website/docs/r/private_key.html.md
resource "tls_private_key" "digitalocean" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Store the ssh keys into keyvault
resource "azurerm_key_vault_secret" "do_private_key" {
  name         = "DigitalOceanVpnDropletSshPrivateKey"
  value        = tls_private_key.digitalocean.private_key_pem
  key_vault_id = var.keyvault_id
}

resource "azurerm_key_vault_secret" "do_public_key" {
  name         = "DigitalOceanVpnDropletSshPublicKey"
  value        = tls_private_key.digitalocean.public_key_pem
  key_vault_id = var.keyvault_id
}

# Save the public key in DigitalOcean for easy droplet creation
resource "digitalocean_ssh_key" "pub_key" {
  name       = "Terraform Homecloud VPN"
  public_key = tls_private_key.digitalocean.public_key_openssh
}

# Wireguard keys
resource "wireguard_asymmetric_key" "wg_server_key" {}

resource "azurerm_key_vault_secret" "wg_server_public_key" {
  name         = "DigitalOceanVpnWgServerPublicKey"
  value        = wireguard_asymmetric_key.wg_server_key.public_key
  key_vault_id = var.keyvault_id
}

resource "wireguard_asymmetric_key" "wg_peers_keys" {
  count = length(var.users)
}

resource "azurerm_key_vault_secret" "wg_peers_private_keys" {
  count = length(var.users)

  # Remove - and do titlecase. E.g. gab-sunzi -> GabSunzi
  name         = "DigitalOceanVpnWgPeerPublicKey${replace(title(var.users[count.index]), "-", "")}"
  value        = wireguard_asymmetric_key.wg_peers_keys[count.index].private_key
  key_vault_id = var.keyvault_id
}

# Prepare the droplet configuration using templates
data "template_file" "peer_data" {
  count = length(var.users)

  template = file("${path.module}/templates/peer-data.tpl")
  vars = {
    peer_name    = var.users[count.index]
    peer_pub_key = wireguard_asymmetric_key.wg_peers_keys[count.index].public_key
    # Peer addresses wil start from 50, eg:192.168.1.50
    peer_ip              = "${cidrhost(local.wg_server_net, count.index + 50)}/32"
    persistent_keepalive = 25
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user-data.tpl")
  vars = {
    wg_server_net         = local.wg_server_net
    wg_server_interface   = "eth0"
    wg_server_private_key = wireguard_asymmetric_key.wg_server_key.private_key
    wg_server_port        = local.wg_server_port
    peers                 = join("\n", data.template_file.peer_data.*.rendered)
  }
}

resource "digitalocean_vpc" "network" {
  name     = "homecloud-network"
  region   = local.region
  ip_range = local.wg_server_net
}

resource "digitalocean_droplet" "vpn1" {
  image     = "ubuntu-21-10-x64"
  name      = "vpn1"
  region    = local.region
  size      = "s-1vcpu-1gb"
  ssh_keys  = [digitalocean_ssh_key.pub_key.fingerprint]
  vpc_uuid  = digitalocean_vpc.network.id
  user_data = data.template_file.user_data.rendered
}

resource "azurerm_key_vault_secret" "do_droplet_id" {
  name         = "DigitalOceanVpnDropletId"
  value        = digitalocean_droplet.vpn1.id
  key_vault_id = var.keyvault_id
}

# Export config files for the peers
data "template_file" "peer_config" {
  count = length(var.users)

  template = file("${path.module}/templates/peer-config.tpl")
  vars = {
    peer_ip             = "${cidrhost(local.wg_server_net, count.index + 50)}/32"
    peer_priv_key       = wireguard_asymmetric_key.wg_peers_keys[count.index].private_key
    wg_server_pub_key   = wireguard_asymmetric_key.wg_server_key.public_key
    wg_server_public_ip = digitalocean_droplet.vpn1.ipv4_address
    wg_server_port      = local.wg_server_port
  }
}

resource "azurerm_storage_container" "container" {
  name                  = "vpn-configs"
  storage_account_name  = var.storage_account_name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "example" {
  count = length(var.users)

  name                   = "user-${var.users[count.index]}.conf"
  storage_account_name   = var.storage_account_name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"
  source_content         = sensitive(data.template_file.peer_config[count.index].rendered)
}