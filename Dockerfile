FROM debian:stretch

ENV SAMBA_VERSION="2:4.5.8+dfsg-2"

RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y samba=$SAMBA_VERSION smbldap-tools ldap-utils && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --no-install-suggests -y libnss-ldapd && \
    rm -rf /var/cache/apt && \
    rm -rf /etc/samba/smb.conf /var/lib/samba/private/secrets.tdb /etc/smbldap-tools /etc/nslcd.conf /etc/nsswitch.conf

# Setup S6
# We need to run multiple processes, so let's add S6 to the image
ENV S6_VERSION="1.19.1.1"
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / --exclude="./bin" --exclude="./sbin" && \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C /usr ./bin && \
    rm -rf /tmp/*

RUN mkdir -p /log/nslcd && chown -R nobody:nogroup /log

COPY rootfs /

VOLUME ["/etc/samba/smb.conf", "/var/lib/samba/private/secrets.tdb", "/etc/smbldap-tools", "/etc/nslcd.conf"]
EXPOSE 139 445
ENTRYPOINT ["/init"]

CMD ["/usr/sbin/smbd", "-F", "-S", "-D"]
