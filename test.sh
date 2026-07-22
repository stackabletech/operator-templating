#!/usr/bin/env bash

rm -fr work || true
mkdir -p work
GH_ACCESS_TOKEN=unneeded ansible-playbook playbook/playbook.yaml --tags="local" --extra-vars "base_dir=$(pwd) commit_hash=12345 reason='original message'" "$@"
