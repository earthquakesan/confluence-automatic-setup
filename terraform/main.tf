resource "hcloud_server" "main" {
  name        = var.server.name
  image       = var.server.image
  server_type = var.server.type
  public_net {
    ipv4_enabled = var.server.ipv4_enabled
    ipv6_enabled = var.server.ipv6_enabled
  }

  user_data = file(".user_data.sh")
  ssh_keys = [ hcloud_ssh_key.default.name ]
}

resource "hcloud_ssh_key" "default" {
  name       = var.ssh_key.name
  public_key = file(var.ssh_key.location)
}
