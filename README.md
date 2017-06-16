# Docker image for samba with LDAP integration

This is a docker image for samba. It includes everything to run a samba instance using an ldap server as an authentication backend. Additionally, smbldap-tools are installed, so you can manage Samba LDAP users from within the container.

# Prerequisites

Unfortunately, this docker image does not much else than installing the needed software. You still have to write the configuration :( You will need:

- A smb.conf of course!
- A Samba secrets.tdb containing the LDAP user password, which is used to fetch user information.
- A nslcd.conf which contains LDAP credentials as well
- A smbldap-tools directory containing the configuration (just in case you want to manage your users with it)

Additionally, we assume an already-setup directory structure on your LDAP server. That is, you will need a top object containing the tree's SID and sub-trees for People, Groups, Computers and Idmap.

# How to run

The following command creates a container called 'samba', which listens on ports 139 and 445 of your host machine. The needed configuration files are mounted directly inside the container. The tree's domain is TESTDOMAIN.

```
/usr/bin/docker run -it --name samba -p 139:139 -p 445:445 -v /smb.conf:/etc/samba/smb.conf -v /secrets.tdb:/var/lib/samba/private/secrets.tdb -v /smbldap-tools:/etc/smbldap-tools -v /nslcd.conf:/etc/nslcd.conf -v /some/share:/some/share --link ldap:ldap -h TESTDOMAIN marcoh00/samba-ldap
```

Please change accordingly if you do not need to link or ldap server or you use another approach for shared folders.

# Help!

In case you need to setup your LDAP server's structure, [Ubuntu's documentation got you covered](https://help.ubuntu.com/lts/serverguide/samba-ldap.html). It contains pretty good advice on setting up LDAP's structure and using smbldap-tools in general.

You can get a valid secerts.tdb for example by running the container with an appended "bash" argument and using "smbpasswd -w". Then copy it out of the container using `docker cp`.

As for the other configuration items, here are some minimal configuration files which should work:

smb.conf:
```
[global]
   workgroup = TESTDOMAIN
   dns proxy = no

   passdb backend = ldapsam:ldap://[LDAPHOSTNAME]
   ldap suffix = dc=TESTDOMAIN
   ldap user suffix = ou=LocalPeople
   ldap group suffix = ou=LocalGroups
   ldap machine suffix = ou=LocalComputers
   ldap idmap suffix = ou=LocalIdmap
   ldap admin dn = cn=LocalAdmin,dc=TESTDOMAIN
   ldap ssl = no
   ldap passwd sync = yes
   
   security = user
   
[AShare]
    comment = Some share
    path = /some/share
    browseable = yes
    read only = no
    valid users = usera userb
```

nslcd.conf:
```
uid nslcd
gid nslcd
uri ldap://[LDAPHOSTNAME]
base ou=LocalPeople,dc=TESTDOMAIN
binddn cn=LocalAdmin,dc=TESTDOMAIN
bindpw [BINDPW]
```

smbldap-tools/smbldap.conf
```
sambaDomain="TESTDOMAIN"
slaveLDAP="[LDAPHOSTNAME]"
slavePort="389"
masterLDAP="[LDAPHOSTNAME]"
masterPort="389"
ldapTLS="0"
verify=""
cafile=""
clientcert=""
clientkey=""
suffix="dc=TESTDOMAIN"
usersdn="ou=LocalPeople,dc=TESTDOMAIN"
computersdn="ou=LocalComputers,dc=TESTDOMAIN"
groupsdn="ou=LocalGroups,dc=TESTDOMAIN"
idmapdn="ou=LocalIdmap,dc=TESTDOMAIN"
sambaUnixIdPooldn="sambaDomainName=TESTDOMAIN,${suffix}"
scope="sub"
hash_encrypt="SSHA"
crypt_salt_format=""
userLoginShell="/bin/bash"
userHome="/home/%U"
userHomeDirectoryMode="700"
userGecos="System User"
defaultUserGid="513"
defaultComputerGid="515"
skeletonDir="/etc/skel"
defaultMaxPasswordAge="45"
userSmbHome="\\\%U"
userProfile="\\\profiles\%U"
userHomeDrive=""
userScript=""
mailDomain="TESTDOMAIN"
with_smbpasswd="0"
smbpasswd="/usr/bin/smbpasswd"
with_slappasswd="0"
slappasswd="/usr/sbin/slappasswd"
```

smbldap-tools/smbldap_bind.conf
```
slaveDN="cn=LocalAdmin,dc=TESTDOMAIN"
slavePw="[BINDPW]"
masterDN="cn=LocalAdmin,dc=TESTDOMAIN"
masterPw="[BINDPW]"
```
