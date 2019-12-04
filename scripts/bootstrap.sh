#!/bin/bash
# Automatic restart services.
echo '* libraries/restart-without-asking boolean true' \
  | debconf-set-selections
# First provision
if [ ! -e /usr/bin/python ]; then
	apt-get update --fix-missing
	apt-get install -yq python-minimal
fi
test -e /usr/bin/pip || apt-get install -yq python-pip
test -e /usr/bin/ansible || pip install ansible
PROVISION_PATH=/vagrant/provision
# Install roles only when there is a list.
if (grep -E -- "^- " $PROVISION_PATH/requirements.yml > /dev/null); then
	ansible-galaxy install \
	    -r $PROVISION_PATH/requirements.yml \
	    -p $PROVISION_PATH/roles
fi
