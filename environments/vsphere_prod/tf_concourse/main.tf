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
  vmtemp          = "tf-centos8-tmpl"
  instances       = 1
  cpu_number      = 2
  ram_size        = 2096
  vmname          = "bs-concoursemstr01"
  vmdomain        = "bsorenson.io"
  vmrp            = "dev"
  network_cards = ["Server VLAN"]
  ipv4submask   = ["24"]
  ipv4 = {
    "Server VLAN" = ["10.0.30.31"] # To use DHCP create Empty list for each instance
  }
  data_disk_size_gb = [10] //Additional Disk to be used
  disk_label        = ["Concourse_volume"]
  scsi_type         = "lsilogic"
  scsi_controller   = 2
  disk_datastore    = "wdBlue"
  data_disk_datastore   = ["wdBlue"]
  network_type      = ["vmxnet3"]
  tags              = {
      "rubrik-backup-strategy"      = "just-testing-policy"
      "Sumologic-monitoring-group"  = "just-testing-policy"

  }
  dc        = "bsorenson.io"
  datastore = "wdBlue"
  extra_config = {
      "guestinfo.userdata"          = base64encode(file("${path.module}/templates/userdata.yaml"))
      "guestinfo.userdata.encoding" = "base64"
  }

}

module "vm_provision" {
  source          = "../../../modules/provisioner"
  conn_type       = "ssh"
  ssh_user        = "svc-tf-dev"
  host            = module.concourse-ci.Linux-guest-ip
  ssh_key         = "C:\Users\xiguazhi\.ssh\id_rsa"
  bootstrap_name  = "bootstrap.sh"
}
