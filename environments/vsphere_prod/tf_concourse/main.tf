provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

module "concourse-ci" {
  source        = "../../../modules/vsphere_linux_vm"
  dc              = "bsorenson.io"
  datastore       = "wdBlue"
  dc_abreviation  = "bs"
  environment     = "p"
  vmtemp          = "tf-centos8-tmpl"
  instances       = 1
  cpu_number      = 2
  ram_size        = 2096
  vmname          = "concoursemstr"
  vmdomain        = "bsorenson.io"
  vmrp            = "prod"
  network_cards = ["Server VLAN"]
  ipv4submask   = ["24"]
  extra_config = {
    "guestinfo.userdata"          = base64encode(file("${path.module}/files/kickstart.yaml"))
    "guestinfo.userdata.encoding" = "base64"
  }
  ipv4 = {
    "Server VLAN" = ["10.0.30.31"] # To use DHCP create Empty list for each instance
  }
  
  network_type      = ["vmxnet3"]
}
