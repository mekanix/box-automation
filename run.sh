#!/bin/sh

export ANSIBLE_HOST_KEY_CHECKING=False

pkg install -y py37-ansible python
ansible-playbook -i provision/inventory/localhost provision/site.yml -c local
