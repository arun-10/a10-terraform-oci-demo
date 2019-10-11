variable "app_display_name" {
  default = ""
}

variable "next_hop_ip" {
}
variable "client_vnic_private_ip" {
}


variable "floating_server_private_ip" {
}

variable "floating_client_private_ip" {
}

variable "mgmt_default_gateway" {
}

variable "client_vnic_private_ip2" {
}

variable "virtual_server_ip" {
}

variable "virtual_server_ip2" {
}

variable "compartment_id" {
description = "Compartment OCID"
default = "adas"
}

variable "vnic_ip1" {
}

variable "vm_availability_domain" {
description = "VM availability domain"
}

variable "vm_display_name1" {
description = "VM display name"
}
variable "vm_display_name2" {
description = "VM display name"
}

variable "vm_shape" {
description = "VM shape"
}

variable "vm_primary_vnic_display_name" {
description = "VM primary VNIC display name"
}

variable "vm_ssh_public_key_path" {
description = "VM ssh public key file path"
}

variable "vm_creation_timeout" {
description = "VM creation timeout"
}

variable "vm_app_shape" {
  default = "VM.Standard2.1"
}

variable "oci_subnet_id1" {
  description = "oci_subnet_id"
}

variable "oci_subnet_id3" {
  description = "oci_subnet_id"
}

variable "tenancy_ocid" {
description = "tenancy ocid"
}

variable "vThunder__image_ocid" {
}

data "oci_core_images" "vThuder_image" {
  compartment_id = "${var.tenancy_ocid}"
 }
locals {
  vThunder__image_ocid = "${var.vThunder__image_ocid}"
  }

resource "oci_core_instance" "vthunder_vm" {
  compartment_id = "${var.compartment_id}"
  display_name = "${var.vm_display_name1}"
  availability_domain = "${var.vm_availability_domain}"

  source_details {
    source_id = "${local.vThunder__image_ocid}"
    source_type = "image"
  }

  shape = "${var.vm_shape}"

  create_vnic_details {
    subnet_id = "${var.oci_subnet_id1}"
    display_name = "${var.vm_primary_vnic_display_name}"
    assign_public_ip = true
  }
  metadata {
    ssh_authorized_keys = "${file( var.vm_ssh_public_key_path )}"
  }
  timeouts {
    create = "${var.vm_creation_timeout}"
  }
}


resource "oci_core_instance" "vthunder_vm2" {
  compartment_id = "${var.compartment_id}"
  display_name = "${var.vm_display_name2}"
  availability_domain = "${var.vm_availability_domain}"

  source_details {
    source_id = "${local.vThunder__image_ocid}"
    source_type = "image"
  }

  shape = "${var.vm_shape}"

  create_vnic_details {
    subnet_id = "${var.oci_subnet_id1}"
    display_name = "${var.vm_primary_vnic_display_name}"
    assign_public_ip = true
  }
  metadata {
    ssh_authorized_keys = "${file( var.vm_ssh_public_key_path )}"
  }
  timeouts {
    create = "${var.vm_creation_timeout}"
  }
}

##APP SERVER###

resource "oci_core_instance" "app-server" {
  compartment_id = "${var.compartment_id}"
  display_name = "${var.app_display_name}"
  availability_domain = "${var.vm_availability_domain}"

  source_details {
    source_id = "ocid1.image.oc1.iad.aaaaaaaaek6aecdnja3rc6qmimbv4x3cipl5b4mknkxlp4xqpmjbbv43dloa"
    source_type = "image"
  }

  shape = "${var.vm_app_shape}"

  create_vnic_details {
    subnet_id = "${var.oci_subnet_id3}"
    assign_public_ip = false  }
  metadata {
    ssh_authorized_keys = "${file( var.vm_ssh_public_key_path )}"
    user_data = "${base64encode(file("user_data.sh"))}"

  }
  timeouts {
    create = "${var.vm_creation_timeout}"
  }
}





resource "null_resource" "test1" {
  provisioner "local-exec" {
    command = <<EOT
          sleep 6m;
          ansible-playbook playbook_wo_vrrp.yaml --extra-vars "a10_host='${oci_core_instance.vthunder_vm.public_ip}'  a10_host2='${oci_core_instance.vthunder_vm2.public_ip}' a10_password='${element(split(".",oci_core_instance.vthunder_vm.id), 4)}' slb_server_host='${oci_core_instance.app-server.private_ip}' server_nic_IP='${var.virtual_server_ip}' server_nic_IP2='${var.virtual_server_ip2}' virtual_server='${var.vnic_ip1}' client_nic_ip='${var.client_vnic_private_ip}' next_hop_ip='${var.next_hop_ip}' floating_client_private_ip='${var.floating_server_private_ip}'  floating_server_private_ip='${var.floating_client_private_ip}' device_id='1' mgmt_default_gateway='${var.mgmt_default_gateway}' ";

          ansible-playbook playbook.yaml --extra-vars "a10_host='${oci_core_instance.vthunder_vm.public_ip}'  a10_host2='${oci_core_instance.vthunder_vm2.public_ip}' a10_password='${element(split(".",oci_core_instance.vthunder_vm.id), 4)}' slb_server_host='${oci_core_instance.app-server.private_ip}' server_nic_IP='${var.virtual_server_ip}' server_nic_IP2='${var.virtual_server_ip2}' virtual_server='${var.vnic_ip1}' client_nic_ip='${var.client_vnic_private_ip}' next_hop_ip='${var.next_hop_ip}' floating_client_private_ip='${var.floating_server_private_ip}'  floating_server_private_ip='${var.floating_client_private_ip}' device_id='1' ";

EOT
  }
  depends_on = ["oci_core_instance.vthunder_vm"]
}

resource "null_resource" "test2" {
  provisioner "local-exec" {
    command = <<EOT
    sleep 6m;
    ansible-playbook playbook_wo_vrrp.yaml --extra-vars "a10_host='${oci_core_instance.vthunder_vm2.public_ip}' a10_host2='${oci_core_instance.vthunder_vm.public_ip}' a10_password='${element(split(".",oci_core_instance.vthunder_vm2.id), 4)}' slb_server_host='${oci_core_instance.app-server.private_ip}' server_nic_IP='${var.virtual_server_ip2}' server_nic_IP2='${var.virtual_server_ip}' virtual_server='${var.vnic_ip1}' client_nic_ip='${var.client_vnic_private_ip2}' next_hop_ip='${var.next_hop_ip}'
    floating_client_private_ip='${var.floating_server_private_ip}' floating_server_private_ip='${var.floating_client_private_ip}' device_id='2'  mgmt_default_gateway='${var.mgmt_default_gateway}' ";

      ansible-playbook playbook.yaml --extra-vars "a10_host='${oci_core_instance.vthunder_vm2.public_ip}' a10_host2='${oci_core_instance.vthunder_vm.public_ip}' a10_password='${element(split(".",oci_core_instance.vthunder_vm2.id), 4)}' slb_server_host='${oci_core_instance.app-server.private_ip}' server_nic_IP='${var.virtual_server_ip2}' server_nic_IP2='${var.virtual_server_ip}' virtual_server='${var.vnic_ip1}' client_nic_ip='${var.client_vnic_private_ip2}' next_hop_ip='${var.next_hop_ip}'
      floating_client_private_ip='${var.floating_server_private_ip}' floating_server_private_ip='${var.floating_client_private_ip}' device_id='2'";

EOT
  }
  depends_on = ["oci_core_instance.vthunder_vm2"]
}



resource "null_resource" "test3" {
  provisioner "local-exec" {
    command = <<EOT
    ansible-playbook playbook_backup.yaml --extra-vars "a10_host='${oci_core_instance.vthunder_vm.public_ip}' a10_password='${element(split(".",oci_core_instance.vthunder_vm.id), 4)}' ";
    ansible-playbook playbook_backup.yaml --extra-vars "a10_host='${oci_core_instance.vthunder_vm2.public_ip}' a10_password='${element(split(".",oci_core_instance.vthunder_vm2.id), 4)}' ";

EOT
      }
    depends_on = ["null_resource.test2"]

    }



output "ip" {value = "${oci_core_instance.vthunder_vm.*.public_ip}"}
output "ip2" {value = "${oci_core_instance.vthunder_vm2.public_ip}"}

output "backend_server_ip" {value = "${element(oci_core_instance.app-server.*.private_ip,0)}"}

output "instance_id" { value = "${oci_core_instance.vthunder_vm.id}" }
output "instance_id2" { value = "${oci_core_instance.vthunder_vm2.id}" }
output "password" { value = "${element(split(".",oci_core_instance.vthunder_vm.id), 4)}" }
output "password2" { value = "${element(split(".",oci_core_instance.vthunder_vm2.id), 4)}" }
