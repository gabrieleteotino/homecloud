output "vpn_host_ip" {
  value = digitalocean_droplet.vpn1.ipv4_address
}

output "vpn_host_id" {
  value = digitalocean_droplet.vpn1.id
}

output "vpn_host_name" {
  value = digitalocean_droplet.vpn1.name
}

output "vpn_host_private_key_secret_name" {
  value = azurerm_key_vault_secret.do_private_key.id
}