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
  vmname          = "bs-concoursemstr01"
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
  data_disk_size_gb = [10] //Additional Disk to be used
  disk_label        = ["Concourse_volume"]
  disk_datastore    = "wdBlue"
  data_disk_datastore   = ["wdBlue"]
  network_type      = ["vmxnet3"]
  tags              = {
      "rubrik-backup-strategy"      = "just-testing-policy"
      "Sumologic-monitoring-group"  = "just-testing-policy"

  }

}

module "vm_provision" {
  source          = "../../../modules/provisioner"
  public_ip       = module.concourse-ci.*.ipv4_address
  conn_type       = "ssh"
  ssh_user        = "svc-tf-dev"
  ssh_key         = "C:/Users/xiguazhi/.ssh/id_rsa"
  bootstrap_name  = "bootstrap.sh"
}
