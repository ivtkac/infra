#!/bin/bash
# Doing Cold Backups for Podman Volumes

BACKUP_DIR="/var/backups/podman/"

volumes=$(podman volume ls -q)
containers=$(podman ps -q)
timestamp=$(date +%Y%m%d%H%M%S)

echo "Pausing containers for backup"
podman pause "$containers"

pushd "${BACKUP_DIR}" || exit 1

for volume in $volumes; do
  echo "Backing up volume $volume..."
  if ! podman volume export "${volume}" --output "${volume}.tar"; then
    echo "Failed to backup volume $volume"
    exit 1
  fi
done

echo "Resuming containers"
podman unpause "$containers"

echo "Combining backups into a single archive..."
if tar -czvf "podman-backup-${timestamp}.tar.gz" --exclude="podman-backup-*.tar.gz" *.tar; then
  echo "Backup completed successfully"
  find . -maxdepth 1 -type f -name '*.tar' ! -name 'podman-backup-*.tar.gz' -exec rm -f {} \;
else
  echo "An error occured during archiving, no files have been deleted."
  exit 1
fi

echo "Removing archives older than 30 days"
if ! find . -maxdepth 1 -type f -name '*.tar.gz' ! -name "podman-backup-*.tar.gz" -mtime +30 -exec rm -f {} \;; then
  echo "Failed to remove old backups"
  exit 1
fi

echo "Backup Complete"

popd || exit 1
