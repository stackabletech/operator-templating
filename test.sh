#!/usr/bin/env bash
export ANSIBLE_VARS_ENABLED=repositories
ansible-playbook playbook/playbook.yaml --tags "local" --extra-vars "gh_access_token=unneeded base_dir=$(pwd) commit_hash=12345 reason='original message' only_operator=hbase-operator"
