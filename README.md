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
VirtualBox, VirtualBox Guest Additions and Vagrant (minimum version >= 1.8.1)

### Setup Vagrant Environment

Install Oracle VirtualBox

```bash
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

Pull a Ubuntu-Trusy64 box or another base box
```bash
vagrant box add ubuntu/trusty64
```


#### Proxy Environment

To run the box behind a proxy set the appropriate
environment variables in ~/.bashrc
```bash
export http_proxy="http://proxy.example.de:800"
export https_proxy="http://proxy.example.de:800"
export no_proxy="localhost, 127.0.0.1, .example.de"
```

and install the vagrant-proxyconf plugin
```bash
vagrant plugin install vagrant-proxyconf
```

Also set the variable 'use_proxy: true' in Vagrantparams.yml


### Installation

Check-out git repo
```bash
git clone https://github.com/tudrescu/ansible-elk-box.git
cd ~/ansible-elk-box
```

Configure environment & start provisioning
```bash
cd ~/ansible-elk-box
vagrant up
```

To change defaults, or use a proxy, edit Vagrantparams.yaml before running
```bash
vagrant up
```

Supported variables in Vagrantparams.yaml.

    vm_cpus: 2                                  # number of CPUs reserved for the VM, 2 is minimum
    vm_memory: 6144                             # memory, 4GB is the minimum recommended
    vm_base_box: "ubuntu/trusty64"              # Hashicorp stock Ubuntu 14.04

    vbguest_auto_update: true                   # update the Virtual Guest Box Additions automatically. 
                                                # Bug: Sometimes the version is incorectly reported causing 
                                                # an upgrade each time the VM is powered up. 
                                                # Disable auto update after provisioning if that is the case.
          
    use_proxy: false                            # when the VM host is behind a proxy

    ansible_tags: common, java, elasticsearch   # select modules

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


Other Vagrant commands

```bash
vagrant box list                             # display boxes
vagrant box remove

vagrant up                                   # starts the machine
vagrant ssh                                  # ssh to the machine
vagrant halt                                 # shutdown the machine
vagrant provision                            # apply the bash/ansible provisioning

vagrant package --output box_name            # save/package vagrant box
vagrant box add name-of-this-box box_name
```

### Usage

After provisioning, the modules are available under

```bash
guest: 5601, host: 25601        # Kibana port
guest: 9200, host: 29200        # Elasticsearch http
guest: 9300, host: 29300        # Elasticsearch tcp
guest: 8080, host: 28080        # Jenkins
guest: 8082, host: 38082        # Apache
guest: 3306, host: 43306        # MySQL
```

on the Vagrant guest VM, and the Vagrant host respectively.
