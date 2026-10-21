# Settings for the backup scripts, sourced by them, never run
# directly — which is why there is no shebang. The directive below
# tells ShellCheck which shell to judge it by.
# shellcheck shell=bash
#
# The two settings are used by the scripts that source this file,
# not by anything in it, so the unused-variable warning is a false
# alarm here. It is disabled for this file only, and this comment
# is the record of why.
# shellcheck disable=SC2034
BACKUP_ROOT=/mnt/backupdrive
RETENTION_DAYS=14
