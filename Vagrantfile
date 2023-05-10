VM_CPUS="2"
VM_MEM="2048"


Vagrant.configure("2") do |config|
  config.vm.box = "rafaelzt/debian-11.6"
  config.vm.box_version = "0.1.1"
  # Disable USB 2.0 Support
  config.vm.provider "virtualbox" do |vb|
   vb.customize ["modifyvm", :id, "--usb", "on"]
   vb.customize ["modifyvm", :id, "--usbehci", "off"]
  end

  config.vm.define "born2beroot" do |vb|
    vb.vm.hostname = "debian-11"
    vb.vm.network "private_network", ip: "192.168.56.200"
    vb.vm.network "forwarded_port", guest: 4242, host: 4242

    vb.vm.provider "virtualbox" do |v|

      v.name = ENV["VM_NAME"] || "debian-11" # Using ENV_VAR
      v.memory = VM_MEM
      v.cpus = VM_CPUS

    end
  end

  config.vm.provision "shell", path: "_bootstrap.sh"

end
