#!/bin/bash

mkdir -p /var/backups/minecraft || exit 1
pushd /var/backups/minecraft || exit 1

tar -czf minecraf-world-backup.tar.gz /var/minecraft/data/world

rsync -avZP minecraft-world-backup.tar.gz ivktac@192.168.0.130:/var/backups/minecraft/
