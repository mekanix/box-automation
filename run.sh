#!/bin/bash

export ANSIBLE_HOST_KEY_CHECKING=False

pkg install -y ansible
ansible-playbook -i provision/inventory/localhost provision/site.yml -c local
