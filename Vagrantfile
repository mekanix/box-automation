# -*- mode: ruby; -*-
Vagrant.configure("2") do |config|
  config.vm.guest = :freebsd
  config.vm.box_url = "http://iris.hosting.lv/freebsd-10.1-amd64.box"
  config.vm.box = "freebsd"
  config.vm.network "private_network", ip: "10.0.1.10"
  config.vm.provision :ansible do |ansible|
    ansible.playbook = "provision/site.yml"
    ansible.host_key_checking = false
  end
end
