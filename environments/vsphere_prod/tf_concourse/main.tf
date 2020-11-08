module "vsphere_tags" {
  source                = "../../../modules/vsphere/vsphere_tags"
  tag_category          = "CreatedOn"
  category_cardinality  = "SINGLE"
  tag                   = "${formatdate("DD MM YYYY hh:mm ZZZ",timestamp())}"
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
  vmgateway     = "10.0.30.1"
  ipv4 = {
    "Server VLAN" = ["10.0.30.31"] # To use DHCP create Empty list for each instance
  }
  network_type      = ["vmxnet3"]
  conn_type         = "ssh"
  ssh_user          = "svc-tf-dev"
  ssh_key           = "C:/User/xiguazhi/.ssh/id_rsa"
}

module "provisioner" {
  source            = "../../../modules/provisioner"
  conn_type         = "SSH"
  public_ip         = "${module.concourse-ci.Linux-ip}"
  ssh_user          = "svc-tf-dev"
  ssh_key           = "C:/Users/xiguazhi/.ssh/id_rsa"
  bootstrap_name    = "./bootstrap.sh"

}