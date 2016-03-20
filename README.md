# Setup Notes

This Vagrant Box provides
  - Elasticsearch
  - Logstash
  - Kibana
  - Apache + MapProxy
  - MySQL
  - Jenkins

Ansible is used to provision the box.

### Prerequisites
VirtualBox, VirtualBox Guest Additions and Vagrant (minimum version >= 1.7.4)

### Setup Vagrant Environment

Install Oracle VirtualBox

```bash
sudo apt-get update
sudo apt-get install linux-headers-generic build-essential dkms
mkdir -p /tmp/vagrant_install && cd /tmp/vagrant_install
wget "http://download.virtualbox.org/virtualbox/5.0.16/virtualbox-5.0_5.0.16-105871~Ubuntu~trusty_amd64.deb"
sudo dpkg -i virtualbox*.deb
rm -rf virtualbox*.deb
```

```
echo "deb http://download.virtualbox.org/virtualbox/debian vivid contrib" | sudo tee -a /etc/apt/sources.list.d/virtualbox.list

wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -

sudo apt-get update
sudo apt-get install virtualbox-5.0
```

Optional - Install Virtual Box Guest Additions
```bash
mkdir -p /tmp/vagrant_install && cd /tmp/vagrant_install
wget "https://www.virtualbox.org/download/testcase/VBoxGuestAdditions_5.0.17-105945.iso"
sudo mkdir /media/VBoxGuestAdditions
sudo mount -o loop,ro VBoxGuestAdditions_* /media/VBoxGuestAdditions
sudo sh /media/VBoxGuestAdditions/autorun.sh
rm VBoxGuestAdditions_*
sudo umount /media/VBoxGuestAdditions
sudo rmdir /media/VBoxGuestAdditions
```

Install latest Vagrant [Vagrant Downloads](http://www.vagrantup.com/downloads.html)

```bash
VAGRANT_VERSION="1.8.1"
mkdir -p /tmp/vagrant_install && cd /tmp/vagrant_install  
wget "https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.deb"
sudo dpkg -i vagrant*.deb
rm -rf vagrant*.deb
# make sure that the ~/.vagrant.d directory is readable/writable
```

Install vagrant-proxyconf to run the box behind a proxy
```bash
vagrant plugin install vagrant-proxyconf
```

Pull Ubuntu Trusy64 box
```bash
vagrant box add ubuntu/trusty64
```

Check-out Git repo
```bash
```

Configure Environment

Edit Vagrantparams.yaml to change defaults and then run
```bash
vagrant up
```

Supported variables in Vagrantparams.yaml:

    vm_cpus: 2                          # number of CPUs reserved for the VM, 2 is minimum
    vm_memory: 6144                     # RAM, 4GB is the minimum required
    vm_base_box: "ubunt/trusty64"       # Hashicorp stock Ubuntu 14.04

    java_useproxy: true                 # controls the use of Proxy for Java-based Apps
    ansible_tags:                       # select modules, default is all

Available ansible_tags

    common
    java
    elasticsearch
    kibana
    logstash
    apache2
    mapproxy
    mysql
    jenkins


Vagrant commands

```bash

vagrant box list       # display boxes
vagrant box remove

vagrant up             # starts the machine
vagrant ssh            # ssh to the machine
vagrant halt           # stutdown the machine
vagrant provision      # apply the bash/ansible provisioning

vagrant package --output box_name            # save/package vagrant box
vagrant box add name-of-this-box box_name
```

Disable vbguest autoupdate after first run.
