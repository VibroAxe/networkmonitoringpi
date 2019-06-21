#!/bin/bash

autossh -f -2 -N -q -M 0 -o "ExitOnForwardFailure yes" -o "PubkeyAuthentication=yes" -o "PasswordAuthentication=no" -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -i /root/.ssh/autossh/id_ed25519 -R 2223:localhost:22 -b 10.20.70.71 -N autossh@bastion.your.tld
