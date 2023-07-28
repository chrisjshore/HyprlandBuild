# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "cshore/fedora38-sway"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.customize ["modifyvm", :id, "--vram", "64"]
    vb.customize ["setextradata", :id, "GUI\/LastGuestSizeHint", "1440,900"]
  #  vb.memory = "16384"
  end

  config.vm.provision "shell" do |s|
    s.path = "provision.sh"
    s.reboot = true
  end
end
