# Skel - Single

Skel for a vagrant multiple machine development environment.

Steps:

1. Create file `~/.ansible_secret/vault_pass_insecure` and put a generic pass in it
1. Exec `direnv allow`
1. Provision ip address at `/etc/hosts` in 192.168.4.0 network
1. Update `Vagrantfile` with node names and ip addresses
1. Update `ansible/hosts-dev.ini` with node names and ip addresses (use hosts-prod.ini for production hosts)
1. Update file/folder `ansible/host_vars/nodeX*` with real names
1. Update file/folder `ansible/group_vars/nodeX_servers*` with real names
1. Update `ansible/requirements.yml` (don't put submodules roles in requirements)
1. Update `ansible/playbook.yml` (and related playbooks like common.yml and dev-only.yml)

Other optional steps:

- Put directive config.vm.synced_folder in Vagrantfile for web server projects.
- Uncomment directive v.customize in Vagrantfile if you want to disable VT-x to use with KVM.
- Update config.vm.box in Vagrantfile (defaults to ubuntu/bionic64)
- Uncoment disk related lines to add more disks in Vagrantfile.
