# -*- mode: ruby -*-
# vi: set ft=ruby :

# also add scp???
# vagrant plugin install vagrant-scp

Vagrant.configure("2") do |config|
  #config.vm.box = "geerlingguy/centos7"
  #config.vm.box = "geerlingguy/rockylinux8"
  #config.vm.box = "generic/ubuntu2204"
  config.vm.box = "generic/debian11"
  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provider :virtualbox do |v|
    v.memory = 512
    v.linked_clone = true
  end

  # Application server 1.
  config.vm.define "pw1" do |app|
    app.vm.hostname = "pw-app1.test"
    app.vm.network :private_network, ip: "192.168.56.4"
  end

  # Application server 2.
  config.vm.define "pw2" do |app|
    app.vm.hostname = "pw-app2.test"
    app.vm.network :private_network, ip: "192.168.56.5"
  end

  # LDAP server.
  config.vm.define "ldap" do |db|
    db.vm.hostname = "pw-ldap.test"
    db.vm.network :private_network, ip: "192.168.56.6"
  end
end
