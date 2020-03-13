# Skel - Single

Skel for a vagrant multiple machine development environment.

Steps:

1. Create file `~/.ansible/vault_pass_insecure` and put a generic pass in it
1. Exec `direnv allow`
1. Provision ip address at `/etc/hosts` in 192.168.4.0 network
1. Update `Vagrantfile` with node names and ip addresses
1. Update `provision/hosts` with node names and ip addresses
1. Update file `provision/host_vars/nodeX.yml`
1. Update `provision/requirements.yml`
1. Update `provision/playbook.yml`

Other optional steps:

- Put directive config.vm.synced_folder in Vagrantfile for web server projects.
- Uncomment directive v.customize in Vagrantfile if you want to disable VT-x to use with KVM.
- Uncomment python-mysqldb install in bootstrap.sh if ansible local provisioner uses mysql module.
- Update config.vm.box in Vagrantfile (defaults to ubuntu/bionic64)
- uncoment to add more disks in Vagrantfile.