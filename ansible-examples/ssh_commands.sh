#!/bin/bash

set -x

ssh-keygen -t ed25519 -C "harun default"

ls -la ~/.ssh

cat ~/.ssh/id_ed25519.pub

cat ~/.ssh/id_ed25519

ssh-copy-id -i ~/.ssh/id_ed25519.pub -p 2203 vagrant@127.0.0.1
ssh-copy-id -i ~/.ssh/id_ed25519.pub -p 2204 vagrant@127.0.0.1
ssh-copy-id -i ~/.ssh/id_ed25519.pub -p 2205 vagrant@127.0.0.1

cat ~/.ssh/authorized_keys
