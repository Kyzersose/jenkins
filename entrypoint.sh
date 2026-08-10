#!/usr/bin/env bash
# Grants the jenkins user access to the bind-mounted docker socket, then hands
# off to the stock Jenkins startup script as the unprivileged jenkins user.
#
# This runs on every container start, which matters: the socket is recreated
# (with fresh permissions) whenever the Docker engine restarts, so a one-off
# manual `chmod` does not survive a reboot. This does.
set -euo pipefail

SOCKET=/var/run/docker.sock

if [ -S "$SOCKET" ]; then
  SOCK_GID="$(stat -c '%g' "$SOCKET")"

  if [ "$SOCK_GID" -ne 0 ]; then
    # Native Linux host: the socket belongs to a real 'docker' group. Recreate
    # that GID inside the container and add jenkins to it. Least-privilege path.
    GROUP_NAME="$(getent group "$SOCK_GID" | cut -d: -f1 || true)"
    if [ -z "$GROUP_NAME" ]; then
      GROUP_NAME=docker-host
      groupadd -g "$SOCK_GID" "$GROUP_NAME"
    fi
    usermod -aG "$GROUP_NAME" jenkins
    echo "docker socket: joined group ${GROUP_NAME} (gid ${SOCK_GID})"
  else
    # Docker Desktop hands the socket over as root:root, so there is no
    # non-root group to join. Loosen the mode instead. See notes.md.
    chmod 666 "$SOCKET"
    echo "docker socket: root-owned, applied chmod 666"
  fi
else
  echo "WARNING: ${SOCKET} not mounted - 'docker' steps in pipelines will fail" >&2
fi

exec gosu jenkins /usr/local/bin/jenkins.sh "$@"
