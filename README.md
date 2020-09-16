![](https://img.shields.io/badge/Stability-EndOfLife-black.svg)

## End of Life Statement

This repository is [End of Life](https://github.com/packethost/standards/blob/master/end-of-life-statement.md) that this software is no longer supported nor maintained by Packet or its community.

Flatcar Linux on Packet
===

[![Build Status](https://cloud.drone.io/api/badges/jmarhee/packet-flatcar-linux-upgrade/status.svg)](https://cloud.drone.io/jmarhee/packet-flatcar-linux-upgrade)

To run Flatcar Linux on <a href="https://packet.com">Packet</a>, there are two methods; <a href="https://docs.flatcar-linux.org/os/booting-with-ipxe/">iPXE booting Flatcar Linux</a> using <a href="https://support.packet.com/kb/articles/custom-ipxe">Packet's custom iPXE boot option</a> for a new installation, or <a href="https://docs.flatcar-linux.org/os/update-from-container-linux/">upgrading from Container Linux (formerly CoreOS)</a>, which is the method used here.

This project provisions Packet devices, and performs an in-place upgrade from Container Linux to Flatcar Linux. 

Setup
--

The only required variable is `auth_token`, your <a href="https://www.packet.com/developers/api/">API token for Packet.com</a>, and `count` (the number of servers to provision and configure). Once provided, you can plan and apply this deployment:

```
terraform init 
terraform plan
terraform apply
```

Kubernetes Preconfiguration
--

Beyond the <a href="https://www.terraform.io/docs/providers/packet/index.html">options provided by the Packet Terraform provider</a>, you have the option of pre-installing tools required by Kubernetes to prepare the nodes for creating a cluster, in this case CNI plugins, container runtime, and the `kubeadm` package. 

To enable this, set the `install_kube_tools` variable to `"yes"`, otherwise, this is not installed by default (if you wish to use Flatcar Linux as is, or if you prefer another Kubernetes bootstrapping method, etc.).

