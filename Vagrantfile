# -*- mode: ruby -*-
# vi: set ft=ruby :

# Node 1 config.
$node1_hostname = "node01"
$node1_ip_address = "192.168.4."

# Node 2 config.
$node2_hostname = "node02"
$node2_ip_address = "192.168.4."

# Controller config.
$controller_hostname = "controller01"
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
  config.vm.box = "ubuntu/xenial64"
  config.vm.define $node1 do |machine|
    machine.vm.hostname = $node1
    machine.vm.network "private_network", ip: $node1_ip_address
  end
  config.vm.define $node2 do |machine|
    machine.vm.hostname = $node2
    machine.vm.network "private_network", ip: $node2_ip_address
  end
  config.vm.define $controller_hostname do |machine|
    machine.vm.network "private_network", ip: $controller_ip_address
    machine.vm.synced_folder "~/.ansible", "/tmp/ansible"
    machine.vm.provision "shell", inline: $set_environment_variables, run: "always"
    machine.vm.provision "shell", inline: 'bash -c "test -e /usr/bin/pip || \
      apt-get update && apt-get install -qy python-pip"'
    machine.vm.provision "shell", inline: 'bash -c "test -e /usr/bin/ansible || \
      pip install \'ansible==2.7.14\'"'
    machine.vm.provision "shell", inline: "ansible-galaxy install --force \
      -r /vagrant/provision/requirements.yml \
      -p /vagrant/provision/roles"
    machine.vm.provision "ansible_local" do |ansible|
      ansible.install = false
      # ansible.install_mode = "pip"
      # ansible.version = "2.7.14"
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
