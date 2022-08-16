#!/bin/bash

set -x

ansible all --key-file ~/.ssh/id_ed25519 -i inventory -m ping

# ad-hoc commands
ansible all -i inventory -m ping 
ansible all -m apt -a update_cache=true --become --ask-become-pass
ansible all -m apt -a name=vim-nox --become --ask-become-pass
ansible all -m apt -a name=snapd state=latest --become --ask-become-pass
ansible all -m apt -a upgrade=dist --become --ask-become-pass
ansible-playbook --ask-become-pass playbooks/install_apache.yml
ansible all -m gather_facts | grep ansible_distribution
