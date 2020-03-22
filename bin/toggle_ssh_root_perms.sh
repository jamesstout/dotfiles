#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck source=../.utils
source "$HOME"/.utils
CURRVAL=$(grep ^PermitRootLogin /etc/ssh/sshd_config | awk '{ print $2 }')

if [ -z "$CURRVAL" ] || [ "$CURRVAL" != "no" -a "$CURRVAL" != "yes" ]; then
    odie "Couldn't get current setting: $CURRVAL"
fi

e_debug "Current PermitRootLogin setting: $CURRVAL"

NEWVAL=$([ "$CURRVAL" = "yes" ] && echo "no" || echo "yes")

check_command sed -i "s/PermitRootLogin $CURRVAL/PermitRootLogin $NEWVAL/" /etc/ssh/sshd_config    

e_success "Set PermitRootLogin to $NEWVAL"

check_command service ssh restart

e_success "sshd restarted"
