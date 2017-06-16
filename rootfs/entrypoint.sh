#!/bin/bash

set -e


if [[ -f /var/lib/samba/private/secrets.tdb ]]; then
    echo "[INFO] Setting permissions for /var/lib/samba/private/secrets.tdb"
    chown root:root /var/lib/samba/private/secrets.tdb
    chmod 0600 /var/lib/samba/private/secrets.tdb
else
    echo "[WARN] /var/lib/samba/private/secrets.tdb not found! Please mount it."
fi


if [[ -f /etc/samba/smb.conf ]]; then
    echo "[INFO] Setting permissions for /etc/samba/smb.conf"
    chown root:root /etc/samba/smb.conf
    chmod 0644 /etc/samba/smb.conf
else
    echo "[WARN] /etc/samba/smb.conf not found! Please mount it."
fi

if [[ -d /etc/smbldap-tools ]]; then
    echo "[INFO] Setting permissions for /etc/smbldap-tools"
    chown root:root /etc/smbldap-tools
    chmod 0755 /etc/smbldap-tools
    if [[ -f /etc/smbldap-tools/smbldap.conf ]]; then
        echo "[INFO] Setting permissions for /etc/smbldap-tools/smbldap.conf"
        chown root:root /etc/smbldap-tools/smbldap.conf
        chmod 0644 /etc/smbldap-tools/smbldap.conf
    fi
    if [[ -f /etc/smbldap-tools/smbldap_bind.conf ]]; then
        echo "[INFO] Setting permissions for /etc/smbldap-tools/smbldap_bind.conf"
        chown root:root /etc/smbldap-tools/smbldap_bind.conf
        chmod 0600 /etc/smbldap-tools/smbldap_bind.conf
    fi
else
    echo "[WARN] /etc/smbldap-tools not found! Please mount it."
fi

if [ "${1:0:1}" = '-' ]; then
	set -- smbd "$@"
fi

if [[ -z $@ ]]; then
    echo "[INFO] Command is empty, set to default"
    set -- "/usr/sbin/smbd" "-F" "-S"
fi

echo "[INFO] Running $@"

exec "$@"
