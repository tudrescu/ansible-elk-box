# -*- mode: ruby -*-
# vi: set ft=ruby :

require "yaml"
require "json"
require "uri"

# load custom user preferences
prefs = YAML::load_file("Vagrantparams.yaml")

use_proxy = (prefs.has_key?('use_proxy') ? prefs['use_proxy'] : false)

vm_base_box = (prefs.has_key?('vm_base_box') ? prefs['vm_base_box'] : "ubuntu/trusty64")

ansible_tags = (prefs.has_key?('ansible_tags') ? prefs['ansible_tags'].join(",") : "common")


# Use only half of the available CPU/Memory resources if preferences exceed this threshold
available_vm_cpus = `nproc`.to_i
available_vm_memory = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024

vm_cpus = available_vm_cpus / 2
if prefs.has_key?('vm_cpus')
  vm_cpus = prefs['vm_cpus'].to_i >=  vm_cpus ?  vm_cpus: prefs['vm_cpus']
end

vm_memory = available_vm_memory / 2
if prefs.has_key?('vm_memory')
  vm_memory = prefs['vm_memory'].to_i >=  vm_memory ?  vm_memory: prefs['vm_memory']
end

puts "-----------" * 5
puts "Use proxy : " + use_proxy.to_s
puts "Ansible tags : " + ansible_tags.to_s
puts "VM Base box : " + vm_base_box.to_s
puts "Assigned/Prefs/Available VM CPUs : " + vm_cpus.to_s + "/" + prefs['vm_cpus'].to_s + "/" + available_vm_cpus.to_s
puts "Assigned/Prefs/Available VM Memory : " + vm_memory.to_s + "/" + prefs['vm_memory'].to_s + "/" + available_vm_memory.to_s + " MB"
puts "-----------" * 5


extra_vars_hash = {:java_useproxy => use_proxy}

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
Vagrant.configure(2) do |config|

  # set to false, if you do NOT want to check the correct VirtualBox Guest Additions version when booting this box
  if defined?(VagrantVbguest::Middleware)
    config.vbguest.auto_update = (prefs.has_key?('vbguest_auto_update') ? prefs['vbguest_auto_update'] : true)

    puts "Update VirtualBox Guest Additions : " + config.vbguest.auto_update.to_s

  end

  # configure proxyies for Vagrant, can be side stepped with java_useproxy: false in Vagrantparams.yml
  if (use_proxy && Vagrant.has_plugin?("vagrant-proxyconf"))

    config.proxy.http      = (prefs.has_key?('config_proxy_http') ? prefs['config_proxy_http'] : ENV['http_proxy'])
    config.proxy.https     = (prefs.has_key?('config_proxy_https') ? prefs['config_proxy_https'] : ENV['https_proxy'])
    config.proxy.no_proxy  = (prefs.has_key?('config_no_proxy') ? prefs['config_no_proxy'] : ENV['no_proxy'])

    http_proxy_url = URI.parse(config.proxy.http)

    # build ansible --extra-vars
    extra_vars_hash = {:java_useproxy => use_proxy,
                       :proxy_env => {:http_proxy => config.proxy.http,
                                      :https_proxy => config.proxy.https,
                                      :no_proxy => config.proxy.no_proxy},
                       :java_proxy_host => http_proxy_url.host.to_s,
                       :java_proxy_port => http_proxy_url.port.to_s,
                       :java_no_proxy_host => config.proxy.no_proxy}

  end

  config.vm.box = vm_base_box

  config.vm.network :forwarded_port, guest: 5601, host: 25601        # Kibana port
  config.vm.network :forwarded_port, guest: 9200, host: 29200        # Elasticsearch http
  config.vm.network :forwarded_port, guest: 9300, host: 29300        # Elasticsearch tcp
  config.vm.network :forwarded_port, guest: 8080, host: 28080        # Jenkins
  config.vm.network :forwarded_port, guest: 8082, host: 38082        # Apache
  config.vm.network :forwarded_port, guest: 3306, host: 43306        # MySQL

  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--cpus", vm_cpus, "--memory", vm_memory]
  end

  ansible_extra_vars = JSON.generate(extra_vars_hash).to_s
  puts "Proxy settings : " + ansible_extra_vars.to_s

  config.vm.provision :shell,
     :keep_color => true,
     :path => "bootstrap.sh",
     :args => "-p #{use_proxy} -t #{ansible_tags} -e '#{ansible_extra_vars}'"

end
