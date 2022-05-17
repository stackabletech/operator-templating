#!/usr/bin/env bash

ansible-playbook playbook/playbook.yaml --tags "local" --extra-vars "gh_access_token=unneeded base_dir=$(pwd) commit_hash=12345 reason='original message'"
