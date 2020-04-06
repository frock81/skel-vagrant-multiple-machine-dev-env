# -*- mode: ruby -*-
# vi: set ft=ruby :

# Controller config.
$controller_hostname = "node-ctrl"
$controller_ip_address = "192.168.4.51"

# Node 1 config.
$node1_hostname = "node01"
$node1_ip_address = "192.168.4.52"

# Node 2 config.
$node2_hostname = "node02"
$node2_ip_address = "192.168.4.53"

# Default for machines
$vbox_cpu = 2
$vbox_memory = 2048

# Sets guest environment variables.
# @see https://github.com/hashicorp/vagrant/issues/7015
$set_environment_variables = <<SCRIPT
tee "/etc/profile.d/myvars.sh" > "/dev/null" <<EOF
# Ansible environment variables.
export ANSIBLE_RETRY_FILES_ENABLED=0
EOF
SCRIPT

VAGRANT_ROOT = File.dirname(File.expand_path(__FILE__))

Vagrant.configure("2") do |config|
  config.ssh.insert_key = false
  config.ssh.private_key_path = "./ansible/insecure_private_key"
  config.vm.box = "ubuntu/bionic64"
  config.vm.define $node1_hostname do |machine|
    machine.vm.provider "virtualbox" do |vbox|
      vbox.name = $node1_hostname
      vbox.memory = $vbox_memory
      vbox.cpus = $vbox_cpu
      
      # Uncomment if you want to disable VT-x to use with KVM.
      # vbox.customize ["modifyvm", :id, "--hwvirtex", "off"]

      # Uncoment to add more disks.
      # file_to_disk = File.join(VAGRANT_ROOT, '.vagrant', 'node1-disk1.vdi')
      # unless File.exist?(file_to_disk)
      #   vbox.customize ['createhd', '--filename', file_to_disk, '--size', 500 * 1024]
      # end
      # vbox.customize ['storageattach', :id, '--storagectl',
      #   'SCSI', '--port', 4, '--device', 0, '--type', 'hdd',
      #   '--medium', file_to_disk]
    end
    machine.vm.hostname = $node1_hostname
    machine.vm.network "private_network", ip: $node1_ip_address
  end
  config.vm.define $node2_hostname do |machine|
    machine.vm.provider "virtualbox" do |vbox|
      vbox.name = $node2_hostname
      vbox.memory = $vbox_memory
      vbox.cpus = $vbox_cpu
      
      # Uncomment if you want to disable VT-x to use with KVM.
      # vbox.customize ["modifyvm", :id, "--hwvirtex", "off"]

      # Uncoment to add more disks.
      # file_to_disk = File.join(VAGRANT_ROOT, '.vagrant', 'node2-disk1.vdi')
      # unless File.exist?(file_to_disk)
      #   vbox.customize ['createhd', '--filename', file_to_disk, '--size', 500 * 1024]
      # end
      # vbox.customize ['storageattach', :id, '--storagectl',
      #   'SCSI', '--port', 4, '--device', 0, '--type', 'hdd',
      #   '--medium', file_to_disk]
    end
    machine.vm.hostname = $node2_hostname
    machine.vm.network "private_network", ip: $node2_ip_address
  end
  config.vm.define $controller_hostname do |machine|
    machine.vm.provider "virtualbox" do |vbox|
      vbox.name = $controller_hostname
      vbox.memory = $vbox_memory
      vbox.cpus = $vbox_cpu
      # Uncomment if you want to disable VT-x to use with KVM.
      # vbox.customize ["modifyvm", :id, "--hwvirtex", "off"]
    end
    machine.vm.hostname = $controller_hostname
    machine.vm.network "private_network", ip: $controller_ip_address
    # Vault passwords in home dir in order to not leave the key together with
    # the lock (use to synchronize projects with Dropbox).
    machine.vm.synced_folder "~/.ansible_secret", \
      "/home/vagrant/.ansible_secret"
    machine.vm.synced_folder "ansible", "/etc/ansible"
    machine.vm.provision "shell", inline: $set_environment_variables, \
      run: "always"
    machine.vm.provision "shell", path: "scripts/bootstrap.sh"
    machine.vm.provision "ansible_local" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.install = false
      ansible.provisioning_path = "/etc/ansible"
      ansible.playbook = ENV["ANSIBLE_PLAYBOOK"] ? ENV["ANSIBLE_PLAYBOOK"] \
        : "playbook.yml"
      ansible.inventory_path = "hosts-dev.ini"
      ansible.become = true
      ansible.limit = ENV['ANSIBLE_LIMIT'] ? ENV['ANSIBLE_LIMIT'] : "all"
      ansible.vault_password_file = "/home/vagrant/.ansible_secret/vault_pass_\
        insecure"
      ansible.tags = ENV['ANSIBLE_TAGS']
      ansible.verbose = ENV['ANSIBLE_VERBOSE']
    end
  end
end
