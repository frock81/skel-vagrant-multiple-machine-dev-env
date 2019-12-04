# -*- mode: ruby -*-
# vi: set ft=ruby :

# Node 1 config.
$node1_hostname = "node01"
$node1_ip_address = "192.168.4."

# Node 2 config.
$node2_hostname = "node02"
$node2_ip_address = "192.168.4."

# Controller config.
$controller_hostname = "controller"
$controller_ip_address = "192.168.4."

# Sets guest environment variables.
# @see https://github.com/hashicorp/vagrant/issues/7015
$set_environment_variables = <<SCRIPT
tee "/etc/profile.d/myvars.sh" > "/dev/null" <<EOF
# Ansible environment variables.
export ANSIBLE_RETRY_FILES_ENABLED=0
EOF
SCRIPT

Vagrant.configure("2") do |config|
  config.ssh.insert_key = false
  config.ssh.private_key_path = "./insecure_private_key"
  config.vm.box = "ubuntu/bionic64"
  config.vm.define $node1_hostname do |machine|
    machine.vm.provider "virtualbox" do |vbox|
      vbox.name = $node1_hostname
      vbox.memory = 512
      vbox.cpus = 1
    end
    machine.vm.hostname = $node1_hostname
    machine.vm.network "private_network", ip: $node1_ip_address
  end
  config.vm.define $node2_hostname do |machine|
    machine.vm.provider "virtualbox" do |vbox|
      vbox.name = $node2_hostname
      vbox.memory = 512
      vbox.cpus = 1
    end
    machine.vm.hostname = $node2_hostname
    machine.vm.network "private_network", ip: $node2_ip_address
  end
  config.vm.define $controller_hostname do |machine|
    machine.vm.network "private_network", ip: $controller_ip_address
    machine.vm.synced_folder "~/.ansible", "/tmp/ansible"
    machine.vm.provision "shell", inline: $set_environment_variables, \
      run: "always"
    machine.vm.provision "shell", path: "scripts/bootstrap.sh"
    machine.vm.provision "ansible_local" do |ansible|
      ansible.install = false
      ansible.provisioning_path = "/vagrant/provision"
      ansible.playbook = "playbook.yml"
      ansible.inventory_path = "hosts"
      ansible.become = true
      ansible.limit = "all"
      ansible.vault_password_file = "/tmp/ansible/vault_pass_insecure"
      ansible.tags = ENV['ANSIBLE_TAGS']
      ansible.verbose = ENV['ANSIBLE_VERBOSE']
    end
  end
end
