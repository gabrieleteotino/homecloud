terraform {
  required_version = "~> 1.1.4"

  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }

    tls = {
      source = "hashicorp/tls"
    }

    template = {
      source = "hashicorp/template"
    }

    wireguard = {
      source = "OJFord/wireguard"
      #version = "0.2.1"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}