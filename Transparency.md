# Transparency

## Overview

iRedMail has some good Graphs that describe the mail-flow:

- Inbound: [LINK](https://docs.iredmail.org/images/flow.inbound.png)
- Outbound: [LINK](https://docs.iredmail.org/images/flow.outbound.png)

I've created this topology overview:

[![iRedMail Topology](https://github.com/ansibleguy/sw_iredmail/blob/stable/iRedMail.svg)](https://github.com/ansibleguy/sw_iredmail/blob/stable/iRedMail.svg)


## Script changes
 
For transparency - the changes, made by the [installation script](https://github.com/iredmail/iRedMail) of iRedMail to the system, are documented here.
 
BE AWARE - these changes might change in later versions. I checked them for V1.6.0!

These checks were performed after running the role with its default config.


### Systemd (+13)
 
+ amavis.service (_Interface between MTA and virus scanner/content filters_)
+ clamav-freshclam.service (_ClamAV virus database updater_)
+ dovecot.service (_Dovecot IMAP/POP3 email server_)
+ fail2ban.service
+ nginx.service
+ php7.4-fpm.service (_The PHP 7.4 FastCGI Process Manager_)
+ postfix.service (_ Postfix Mail Transport Agent_)
+ postfix@-.service (_Postfix Mail Transport Agent (instance -)_)
+ uwsgi.service (_LSB: Start/stop uWSGI server instance(s)_)
+ system-postfix.slice
+ phpsessionclean.timer (_Clean PHP session files every 30 mins_)

### Cron-Jobs (+9)

```bash
30   3   *   *   *   /bin/bash /var/vmail/backup/backup_mysql.sh
# iRedAPD: Clean up expired tracking records hourly.
1   *   *   *   *   python3 /opt/iredapd/tools/cleanup_db.py >/dev/null
# iRedAPD: Convert SPF DNS record of specified domain names to IP
#          addresses/networks hourly.
2   *   *   *   *   python3 /opt/iredapd/tools/spf_to_greylist_whitelists.py >/dev/null
# iRedMail: Cleanup Amavisd database
1   2   *   *   *   python3 /opt/www/iredadmin/tools/cleanup_amavisd_db.py >/dev/null
# iRedAdmin: Clean up sql database.
1   *   *   *   *   python3 /opt/www/iredadmin/tools/cleanup_db.py >/dev/null 2>&1
# iRedAdmin: Delete mailboxes on file system which belong to removed accounts.
1   *   *   *   *   python3 /opt/www/iredadmin/tools/delete_mailboxes.py
# iRedMail: Cleanup Roundcube SQL database
2   2   *   *   *   /usr/bin/php /opt/www/roundcubemail/bin/cleandb.sh >/dev/null
# iRedMail: Cleanup Roundcube temporary files under 'temp/' directory
2   2   *   *   *   /usr/bin/php /opt/www/roundcubemail/bin/gc.sh >/dev/null
# Fail2ban: Unban IP addresses pending for removal (stored in SQL db).
* * * * * /bin/bash /usr/local/bin/fail2ban_banned_db unban_db
```

### APT Packages (+288)

+ acl
+ altermime
+ amavisd-new
+ arj
+ binutils-common
+ binutils-x86-64-linux-gnu
+ binutils
+ build-essential
+ cabextract
+ clamav-base
+ clamav-daemon
+ clamav-freshclam
+ clamav
+ clamdscan
+ cpp-10
+ cpp
+ debugedit
+ dialog
+ dirmngr
+ dovecot-core
+ dovecot-imapd
+ dovecot-lmtpd
+ dovecot-managesieved
+ dovecot-mysql
+ dovecot-pop3d
+ dovecot-sieve
+ dpkg-dev
+ fail2ban
+ fakeroot
+ fontconfig-config
+ fonts-dejavu-core
+ g++-10
+ g++
+ gcc-10
+ gcc
+ geoip-bin
+ geoip-database
+ gnupg-l10n
+ gnupg-utils
+ gnupg2
+ gnupg
+ gnustep-base-common
+ gnustep-base-runtime
+ gnustep-common
+ gpg-agent
+ gpg-wks-client
+ gpg-wks-server
+ gpg
+ gpgconf
+ gpgsm
+ javascript-common
+ libalgorithm-diff-perl
+ libalgorithm-diff-xs-perl
+ libalgorithm-merge-perl
+ libarchive-zip-perl
+ libarchive13
+ libasan6
+ libassuan0
+ libatomic1
+ libauthen-sasl-perl
+ libavahi-client3
+ libavahi-common-data
+ libavahi-common3
+ libberkeleydb-perl
+ libbinutils
+ libc-dev-bin
+ libc-devtools
+ libc6-dev
+ libcc1-0
+ libclamav9
+ libcommon-sense-perl
+ libconvert-binhex-perl
+ libconvert-tnef-perl
+ libconvert-uulib-perl
+ libcrypt-dev
+ libcrypt-openssl-bignum-perl
+ libcrypt-openssl-random-perl
+ libcrypt-openssl-rsa-perl
+ libctf-nobfd0
+ libctf0
+ libcurl4
+ libdata-dump-perl
+ libdate-manip-perl
+ libdbd-mysql-perl
+ libdeflate0
+ libdigest-bubblebabble-perl
+ libdigest-hmac-perl
+ libdpkg-perl
+ libdw1
+ liberror-perl
+ libexpat1-dev
+ libexttextcat-2.0-0
+ libexttextcat-data
+ libfakeroot
+ libfile-fcntllock-perl
+ libfile-listing-perl
+ libfont-afm-perl
+ libfontconfig1
+ libgc1
+ libgcc-10-dev
+ libgd3
+ libgeoip1
+ libgnustep-base1.27
+ libgomp1
+ libhtml-form-perl
+ libhtml-format-perl
+ libhtml-tree-perl
+ libhttp-cookies-perl
+ libhttp-daemon-perl
+ libhttp-negotiate-perl
+ libidn11
+ libio-multiplex-perl
+ libio-socket-inet6-perl
+ libio-socket-ssl-perl
+ libio-stringy-perl
+ libisl23
+ libitm1
+ libjbig0
+ libjpeg62-turbo
+ libjs-jquery
+ libjs-sphinxdoc
+ libjs-underscore
+ libjson-perl
+ libjson-xs-perl
+ libksba8
+ liblsan0
+ libltdl7
+ liblua5.2-0
+ liblua5.3-0
+ liblwp-protocol-https-perl
+ liblz4-tool
+ liblzo2-2
+ libmail-authenticationresults-perl
+ libmail-dkim-perl
+ libmail-spf-perl
+ libmailtools-perl
+ libmcrypt4
+ libmhash2
+ libmime-tools-perl
+ libmpc3
+ libmspack0
+ libnet-cidr-lite-perl
+ libnet-cidr-perl
+ libnet-dns-perl
+ libnet-dns-sec-perl
+ libnet-http-perl
+ libnet-ip-perl
+ libnet-libidn-perl
+ libnet-patricia-perl
+ libnet-server-perl
+ libnet-smtp-ssl-perl
+ libnet-snmp-perl
+ libnet-ssleay-perl
+ libnetaddr-ip-perl
+ libnginx-mod-http-auth-pam
+ libnginx-mod-http-dav-ext
+ libnginx-mod-http-echo
+ libnginx-mod-http-geoip2
+ libnginx-mod-http-geoip
+ libnginx-mod-http-image-filter
+ libnginx-mod-http-subs-filter
+ libnginx-mod-http-upstream-fair
+ libnginx-mod-http-xslt-filter
+ libnginx-mod-mail
+ libnginx-mod-stream-geoip2
+ libnginx-mod-stream-geoip
+ libnginx-mod-stream
+ libnorm1
+ libnpth0
+ libnsl-dev
+ libobjc4
+ libonig5
+ libperl4-corelibs-perl
+ libpgm-5.3-0
+ libpython3-dev
+ libpython3.9-dev
+ libpython3.9
+ libquadmath0
+ librpm9
+ librpmbuild9
+ librpmio9
+ librpmsign9
+ libsocket6-perl
+ libsodium23
+ libstdc++-10-dev
+ libstemmer0d
+ libsys-cpu-perl
+ libsys-hostname-long-perl
+ libsys-meminfo-perl
+ libtfm1
+ libtiff5
+ libtirpc-dev
+ libtry-tiny-perl
+ libtsan0
+ libtypes-serialiser-perl
+ libubsan1
+ libunix-syslog-perl
+ libwavpack1
+ libwebp6
+ libwww-perl
+ libwww-robotrules-perl
+ libxpm4
+ libxslt1.1
+ libyaml-0-2
+ libzip4
+ libzmq5
+ linux-libc-dev
+ logwatch
+ lrzip
+ lz4
+ lzop
+ make
+ manpages-dev
+ mcrypt
+ mlmmj
+ nginx-common
+ nginx-core
+ nginx-full
+ nomarch
+ p7zip-full
+ p7zip
+ patch
+ pax
+ perl-openssl-defaults
+ php-cli
+ php-common
+ php-curl
+ php-fpm
+ php-gd
+ php-intl
+ php-json
+ php-mbstring
+ php-mysql
+ php-xml
+ php-zip
+ php7.4-cli
+ php7.4-common
+ php7.4-curl
+ php7.4-fpm
+ php7.4-gd
+ php7.4-intl
+ php7.4-json
+ php7.4-mbstring
+ php7.4-mysql
+ php7.4-opcache
+ php7.4-readline
+ php7.4-xml
+ php7.4-zip
+ pinentry-curses
+ postfix-mysql
+ postfix-pcre
+ postfix
+ python-pip-whl
+ python3-bcrypt
+ python3-dev
+ python3-distutils
+ python3-dnspython
+ python3-jinja2
+ python3-lib2to3
+ python3-markupsafe
+ python3-netifaces
+ python3-pip
+ python3-pyinotify
+ python3-requests
+ python3-setuptools
+ python3-simplejson
+ python3-sqlalchemy-ext
+ python3-sqlalchemy
+ python3-systemd
+ python3-wheel
+ python3.9-dev
+ re2c
+ rpm-common => is removed by role
+ rpm2cpio => is removed by role
+ rpm => is removed by role
+ sa-compile
+ spamassassin
+ spamc
+ ssl-cert
+ tofrodos
+ unar
+ unrar-free
+ unzip
+ uwsgi-core
+ uwsgi-plugin-python3
+ uwsgi
+ whois
+ zlib1g-dev

### Summary provided by script itself

```bash
#
# File generated by iRedMail (2022.08.09.14.04.12):
#
# Version:  1.6.0
# Project:  https://www.iredmail.org/
#
# Community: https://forum.iredmail.org/
#

* Enabled services:  rsyslog postfix mysql nginx php7.4-fpm dovecot clamav-daemon amavis clamav-freshclam fail2ban cron nftables


SSL cert keys (size: 4096):
    - /etc/ssl/certs/iRedMail.crt
    - /etc/ssl/private/iRedMail.key

Mail Storage:
    - Mailboxes: /var/vmail/vmail1
    - Mailbox indexes: 
    - Global sieve filters: /var/vmail/sieve
    - Backup scripts and backup copies: /var/vmail/backup

Virtual Users:
    - /tmp/iredmail/iRedMail-1.6.0/samples/iredmail/iredmail.mysql
    - /tmp/iredmail/iRedMail-1.6.0/runtime/*.sql

Backup MySQL database:
    * Script: /var/vmail/backup/backup_mysql.sh
    * See also:
        # crontab -l -u root

Postfix:
    * Configuration files:
        - /etc/postfix
        - /etc/postfix/aliases
        - /etc/postfix/main.cf
        - /etc/postfix/master.cf

    * SQL/LDAP lookup config files:
        - /etc/postfix/mysql

Dovecot:
    * Configuration files:
        - /etc/dovecot/dovecot.conf
        - /etc/dovecot/dovecot-ldap.conf (For OpenLDAP backend)
        - /etc/dovecot/dovecot-mysql.conf (For MySQL backend)
        - /etc/dovecot/dovecot-pgsql.conf (For PostgreSQL backend)
        - /etc/dovecot/dovecot-used-quota.conf (For real-time quota usage)
        - /etc/dovecot/dovecot-share-folder.conf (For IMAP sharing folder)
    * Syslog config file:
        - /etc/rsyslog.d/1-iredmail-dovecot.conf (present if rsyslog >= 8.x)
    * RC script: /etc/init.d/dovecot
    * Log files:
        - /var/log/dovecot/dovecot.log
        - /var/log/dovecot/sieve.log
        - /var/log/dovecot/lmtp.log
        - /var/log/dovecot/lda.log (present if rsyslog >= 8.x)
        - /var/log/dovecot/imap.log (present if rsyslog >= 8.x)
        - /var/log/dovecot/pop3.log (present if rsyslog >= 8.x)
        - /var/log/dovecot/sieve.log (present if rsyslog >= 8.x)
    * See also:
        - /var/vmail/sieve/dovecot.sieve
        - Logrotate config file: /etc/logrotate.d/dovecot

Nginx:
    * Configuration files:
        - /etc/nginx/nginx.conf
        - /etc/nginx/sites-available/00-default.conf
        - /etc/nginx/sites-available/00-default-ssl.conf
    * Directories:
        - /etc/nginx
        - /var/www/html
    * See also:
        - /var/www/html/index.html

php-fpm:
    * Configuration files: /etc/php/7.4/fpm/pool.d/www.conf

PHP:
    * PHP config file for Nginx: 
    * Disabled functions: posix_uname,eval,pcntl_wexitstatus,posix_getpwuid,xmlrpc_entity_decode,pcntl_wifstopped,pcntl_wifexited,pcntl_wifsignaled,phpAds_XmlRpc,pcntl_strerror,ftp_exec,pcntl_wtermsig,mysql_pconnect,proc_nice,pcntl_sigtimedwait,posix_kill,pcntl_sigprocmask,fput,phpinfo,system,phpAds_remoteInfo,ftp_login,inject_code,posix_mkfifo,highlight_file,escapeshellcmd,show_source,pcntl_wifcontinued,fp,pcntl_alarm,pcntl_wait,ini_alter,posix_setpgid,parse_ini_file,ftp_raw,pcntl_waitpid,pcntl_getpriority,ftp_connect,pcntl_signal_dispatch,pcntl_wstopsig,ini_restore,ftp_put,passthru,proc_terminate,posix_setsid,pcntl_signal,pcntl_setpriority,phpAds_xmlrpcEncode,pcntl_exec,ftp_nb_fput,ftp_get,phpAds_xmlrpcDecode,pcntl_sigwaitinfo,shell_exec,pcntl_get_last_error,ftp_rawlist,pcntl_fork,posix_setuid

ClamAV:
    * Configuration files:
        - /etc/clamav/clamd.conf
        - /etc/clamav/freshclam.conf
        - /etc/logrotate.d/clamav
    * RC scripts:
            + /etc/init.d/clamav-daemon
            + /etc/init.d/clamav-freshclam

Amavisd-new:
    * Configuration files:
        - /etc/amavis/conf.d/50-user
        - /etc/postfix/master.cf
        - /etc/postfix/main.cf
    * RC script:
        - /etc/init.d/amavis
    * SQL Database:
        - Database name: amavisd
        - Database user: amavisd
        - Database password: PWD

DNS record for DKIM support:

; key#1 2048 bits, i=mail, d=DOMAIN.TLD, /var/lib/dkim/DOMAIN.TLD.pem
mail._domainkey.DOMAIN.TLD.   3600 TXT (
  "v=DKIM1; p="
  "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArJlKg35yxpcs5F4Dpt2r"
  "eSTEi5ZOsnexpDx4R56Ytjx9vqziTtG+aB7tPCmQTYoblhW2pabUjDClJXepMZlD"
  "xb66D54IR/cNcp92gH4O1DNiLCmj1WiTkjh3qk2Zv/D1Hhl/5VTALXsEF2qjbS+l"
  "VPPjd9E95CxkTT2GNAP2G4Eh+aZiO+6XxwzbuyqkFpPjEY+0Iz2FZU2wXFz5e3GI"
  "brle9SWrDDVGhujwsjZ1Xbj4eZQGJPmBxpeSfsPMzjeRNf7dgp4m80kKALmPRjlE"
  "OLQNHHGrkl8wGnUT7T5ZPdi0WMAsDurKGLzWYWbS/KF1ZHNIxpCPRAg09iByr4Nx"
  "9QIDAQAB")
SpamAssassin:
    * Configuration files and rules:
        - /etc/mail/spamassassin
        - /etc/mail/spamassassin/local.cf

iRedAPD - Postfix Policy Server:
    * Version: 5.0.4
    * Listen address: 127.0.0.1, port: 7777
    * SQL database account:
        - Database name: iredapd
        - Username: iredapd
        - Password: PWD
    * Configuration file:
        - /opt/iredapd/settings.py
    * Related files:
        - /opt/iRedAPD-5.0.4
        - /opt/iredapd (symbol link to /opt/iRedAPD-5.0.4

iRedAdmin - official web-based admin panel:
    * Version: 1.7
    * Root directory: /opt/www/iRedAdmin-1.7
    * Config file: /opt/www/iRedAdmin-1.7/settings.py
    * Web access:
        - URL: https://SRV.DOMAIN.TLD/iredadmin/
        - Username: admin@DOMAIN.TLD
        - Password: PWD
    * SQL database:
        - Database name: iredadmin
        - Username: iredadmin
        - Password: PWD

Roundcube webmail: /opt/www/roundcubemail-1.5.2
    * Config file: /opt/www/roundcubemail-1.5.2/config
    * Web access:
        - URL: http://SRV.DOMAIN.TLD/mail/ (will be redirected to https:// site)
        - URL: https://SRV.DOMAIN.TLD/mail/ (secure connection)
        - Username: admin@DOMAIN.TLD
        - Password: PWD
    * SQL database account:
        - Database name: roundcubemail
        - Username: roundcube
        - Password: PWD
    * Cron job:
        - Command: "crontab -l -u root"
```
