#!/bin/bash
# Print where backups go, reading the setting from the fragment.
source ./config-fragment.sh
echo "Backups go to $BACKUP_ROOT and stay $RETENTION_DAYS days"
