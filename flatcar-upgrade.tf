provider "packet" {
  version    = "1.3.2"
  auth_token = "${var.auth_token}"
}

resource "packet_project" "flatcar_nodes" {
  name = "Flatcar Linux"
}

resource "random_string" "hostname_key" {
  length  = 6
  special = false
  upper   = false
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.tpl")}"

  vars {
    update_url         = "${var.flatcar_update_url}"
    cni_version = "${var.cni_version}"
    crictl_version = "${var.crictl_version}"
    prepare_kube = "${var.install_kube_tools}"
  }
}

resource "packet_device" "flatcar_node" {
  hostname         = "${format("flatcar-${random_string.hostname_key.result}-%02d", count.index)}"
  count            = "${var.count}"
  operating_system = "coreos_${var.coreos_release_channel}"
  plan             = "${var.plan}"
  facility         = "${var.facility}"
  user_data        = "${data.template_file.user_data.rendered}"

  billing_cycle = "hourly"
  project_id    = "${packet_project.flatcar_nodes.id}"
}
