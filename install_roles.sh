#!/usr/bin/env bash
# run this script to recreate the roles folder
ansible-galaxy install -r ./roles/requirements.yml -f --roles-path=./roles
