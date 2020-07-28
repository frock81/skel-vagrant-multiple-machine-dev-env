# -*- mode: ruby -*-
# vi: set ft=ruby :

# The box to be used by Vagrant.
VAGRANT_BOX = "ubuntu/bionic64"

# Number of CPUs allocated to the virtual machine instances.
VM_CPUS = 2

# Total of RAM memory in megabytes allocated to the vm instances.
VM_MEMORY = 2048

# The prefix for the hostname and virtual machine name.
INSTANCE_PREFIX = "node"

# Start of the nodes. If 0 it will node-0, node-1 and so on. If 1 it will
# be node-0, node-1...
INSTANCE_START=1

# The last instance index. Will determine the amount of nodes. The
# default with INSTANCE_START=1 and INSTANCE_END=2 will give two nodes,
# node-1 and node-2.
INSTANCE_END = 2

# The prefix for the IP address. The ip address for the machines will be
# generated using the instance index and the prefix. So in the default
# confing it will be 192.168.4.11 for node-1, 192.168.4.12 for node-2
# and so on.
IP_PREFIX = "192.168.4.1"

# The virtual machine name and hostname for the controller machine, the
# one that will provision the other with Ansible (manager). It is useful
# for mixed environments that uses Linux, Windows, etc and makes it
# unecessary to have Ansible installed in the machine running Vagrant.
$controller_hostname = "#{INSTANCE_PREFIX}-ctrl"

# The IP address for the controller machine. In the default config it
# will be 192.168.4.10.
$controller_ip_address = "#{IP_PREFIX}0"

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
  config.vm.box = VAGRANT_BOX

  (INSTANCE_START..INSTANCE_END).each do |i|
    config.vm.define "#{INSTANCE_PREFIX}-#{i}" do |machine|
      machine.vm.provider "virtualbox" do |vbox|
        vbox.name = "#{INSTANCE_PREFIX}-#{i}"
        vbox.memory = VM_MEMORY
        vbox.cpus = VM_CPUS

        # Uncomment if you want to disable VT-x to use with KVM.
        # vbox.customize ["modifyvm", :id, "--hwvirtex", "off"]

        # Uncoment to add more disks.
        # disk_size_in_mb = 128
        # disks_total = 4
        # for j in 1..disks_total
        #   file_to_disk = File.join(VAGRANT_ROOT, '.vagrant', "#{INSTANCE_PREFIX}-#{i}-disk-#{j}.vdi")
        #   unless File.exist?(file_to_disk)
        #     vbox.customize ['createmedium', 'disk',
        #       '--filename', file_to_disk,
        #       '--size', disk_size_in_mb,
        #       '--variant', 'Fixed']
        #   end
        #   vbox.customize ['storageattach', :id,
        #     '--storagectl', 'SCSI',
        #     '--port', 2 + j - 1,
        #     '--device', 0,
        #     '--type', 'hdd',
        #     '--medium', file_to_disk]
        # end
      end
      machine.vm.hostname = "#{INSTANCE_PREFIX}-#{i}"
      machine.vm.network "private_network", ip: "#{IP_PREFIX}#{i}"
    end
  end

  # The controller that will provision other nodes.
  config.vm.define $controller_hostname do |machine|
    machine.vm.provider "virtualbox" do |vbox|
      vbox.name = $controller_hostname
      vbox.memory = VM_MEMORY
      vbox.cpus = VM_CPUS

      # Uncomment if you want to disable VT-x to use with KVM.
      # vbox.customize ["modifyvm", :id, "--hwvirtex", "off"]
    end
    machine.vm.hostname = $controller_hostname
    machine.vm.network "private_network", ip: $controller_ip_address
    # Vault passwords in home dir in order to not leave the key together with
    # the lock (useful to synchronize projects inside Dropbox/Gdrive).
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
      ansible.vault_password_file = "/home/vagrant/.ansible_secret/vault_pass_insecure"
      ansible.tags = ENV['ANSIBLE_TAGS']
      ansible.verbose = ENV['ANSIBLE_VERBOSE']
    end
  end
end
