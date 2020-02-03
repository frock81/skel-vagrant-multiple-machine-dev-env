#!/bin/bash

# To fix dpkg error in provisioning.
export DEBIAN_FRONTEND=noninteractive

# Avoid prompting questions.
echo '* libraries/restart-without-asking boolean true' \
  | debconf-set-selections

# Use recent packages.
if [ -z "$(find /var/cache/apt/pkgcache.bin -mmin -1440)" ]; then
  apt update --fix-missing && apt -yq upgrade
fi

# In the first vagrant up, python wont be installed. We use this characteristic
# to update apt sources file.
if ! test -e /usr/bin/python; then
  sed -i 's#http://archive.ubuntu.com#http://br.archive.ubuntu.com#g' \
    /etc/apt/sources.list
  apt update
  apt install -yq python-minimal
fi

# Install Ansible via Python PIP.
test -e /usr/bin/pip || apt install -yq python-pip
test -e /usr/bin/ansible-galaxy || pip install ansible

# Install required roles.
ansible-galaxy install \
    -r /vagrant/provision/requirements.yml \
    -p /vagrant/provision/roles \
    --ignore-errors
