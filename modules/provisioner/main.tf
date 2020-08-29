  
resource "null_resource" "provision" {
    triggers    = {
        public_ip = var.ipv4[var.network_cards[network_interface.key]][count.index]
    }
    connection {
        type    =  var.conn_type
        user    = var.ssh_user
        host    = var.ipv4[var.network_cards[network_interface.key]][count.index]
        private_key     = file("${var.ssh_key}")
        
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