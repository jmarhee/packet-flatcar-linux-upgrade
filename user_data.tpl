#!/bin/bash

function key_mount() {
    curl -L -o /tmp/key https://raw.githubusercontent.com/flatcar-linux/coreos-overlay/flatcar-master/coreos-base/coreos-au-key/files/official-v2.pub.pem && \
    sudo mount --bind /tmp/key /usr/share/update_engine/update-payload-key.pub.pem
}

function modify_configs() {
    echo "SERVER=${update_url}" | sudo tee -a /etc/coreos/update.conf && \
    cp /usr/share/coreos/release /tmp && \
    sudo mount --bind /tmp/release /usr/share/coreos/release && \
    cp /usr/share/coreos/release ~/release.bak && \
    cat /usr/share/coreos/release | sed -e 's|COREOS_RELEASE_VERSION|#COREOS_RELEASE_VERSION|g' | sed -e '1iCOREOS_RELEASE_VERSION=0.0.0' | grep -v "#" | sudo tee /usr/share/coreos/release
}

function update_engine() {
    if [ "$1" == "0" ]; then
        echo "Copying /var/lib/coreos-install/user_data to /var/lib/flatcar-install/user_data..." ; \
        sudo cp -R /var/lib/coreos-install/ /var/lib/flatcar-install/ && \
        echo "Restarting update-engine and performing upgrade (system will be rebooted)" ; \
        sudo systemctl restart update-engine && \
        update_engine_client -update
    else
        echo "Setup failed, code $1" ; exit 2
    fi
}

function install_kube_tools() {
    echo "Installing CNI plugins" ; \
    sudo mkdir -p /opt/cni/bin ; \
    sudo curl -L "https://github.com/containernetworking/plugins/releases/download/${cni_version}/cni-plugins-amd64-${cni_version}.tgz" | sudo tar -C /opt/cni/bin -xz && \
    echo "Installing CRI..." ; \
    sudo mkdir -p /opt/bin ; \
    sudo curl -L "https://github.com/kubernetes-incubator/cri-tools/releases/download/${crictl_version}/crictl-${crictl_version}-linux-amd64.tar.gz" | sudo tar -C /opt/bin -xz && \
    cd /opt/bin ; \
    sudo curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/$(sudo curl -sSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/{kubeadm,kubelet,kubectl} && \
    sudo chmod +x {kubeadm,kubelet,kubectl} && \
    RELEASE="$(sudo curl -sSL https://dl.k8s.io/release/stable.txt)" sudo curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/$(sudo curl -sSL https://dl.k8s.io/release/stable.txt)/build/debs/kubelet.service" | sudo sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service && \
    sudo mkdir -p /etc/systemd/system/kubelet.service.d ; \
    RELEASE="$(sudo curl -sSL https://dl.k8s.io/release/stable.txt)" sudo curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/$(sudo curl -sSL https://dl.k8s.io/release/stable.txt)/build/debs/10-kubeadm.conf" | sudo sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf && \
    sudo systemctl enable --now kubelet
}

echo "Downloading and Mounting Key" ; \
key_mount && \
echo "Modifying Configs for Flatcar Linux Readiness..." ; \
if [ "${prepare_kube}" = "yes" ]; then
    install_kube_tools
else
   echo "Not installing CNI, CRI tools..."
fi
modify_configs && \
update_engine $?