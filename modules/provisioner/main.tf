  
resource "null_resource" "provision" {
    triggers    = {
        public_ip = var.ip_address
    }
    connection {
	    count   = 2
        type    =  var.conn_type
        user    = var.ssh_user
        host    = module.vsphere_vm.ipv4[count.index]
        private_key     = "${file("${var.ssh_key}")}"
        
    }

    provisioner "file" {
        source      = "files/"
        destination = "/tmp/"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo chmod +x /tmp/${var.bootstrap_name}",
            "./tmp/${var.bootstrap_name}"
        ]
    }
}