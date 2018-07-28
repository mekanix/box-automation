#!/bin/sh

export ANSIBLE_HOST_KEY_CHECKING=False

pkg install -y py36-ansible python36
ansible-playbook-3.6 -i provision/inventory/localhost provision/site.yml -c local
