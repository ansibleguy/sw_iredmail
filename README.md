[![iRedMail](https://www.iredmail.org/assets/images/logo-iredmail.png)](https://www.iredmail.org/)

# Ansible Role - iRedMail

Role to deploy iRedMail mail servers.

[![Molecule Test Status](https://badges.ansibleguy.net/sw_iredmail.molecule.svg)](https://molecule.readthedocs.io/en/latest/)
[![YamlLint Test Status](https://badges.ansibleguy.net/sw_iredmail.yamllint.svg)](https://yamllint.readthedocs.io/en/stable/)
[![Ansible-Lint Test Status](https://badges.ansibleguy.net/sw_iredmail.ansiblelint.svg)](https://ansible-lint.readthedocs.io/en/latest/)
[![Ansible Galaxy](https://img.shields.io/ansible/role/59937)](https://galaxy.ansible.com/ansibleguy/sw_iredmail)
[![Ansible Galaxy Downloads](https://img.shields.io/badge/dynamic/json?color=blueviolet&label=Galaxy%20Downloads&query=%24.download_count&url=https%3A%2F%2Fgalaxy.ansible.com%2Fapi%2Fv1%2Froles%2F59937%2F%3Fformat%3Djson)](https://galaxy.ansible.com/ansibleguy/sw_iredmail)

**Tested:**
* Debian 11


## Source Notes

You can find the OpenSource Repository to the software here: [REPO](https://github.com/iredmail/iRedMail/)

The installation script used by the repository is installing and configuring MANY dependencies.

Therefore, I **cannot make the installation transparent** without porting the whole script to Ansible.

As I currently have not got the time to do so - I analyzed the outcome of the script to make it somewhat transparent.

You can see the changes in Systemd, packages and files in this document: [Transparency](https://github.com/ansibleguy/sw_iredmail/blob/stable/Transparency.md)


## Functionality

* **Package installation**
  * Ansible dependencies (_minimal_)
  * MariaDB => using [THIS Role](https://github.com/ansibleguy/infra_mariadb)
  * Nginx => using [THIS Role](https://github.com/ansibleguy/infra_nginx)
  * iRedMail Setup Script
    * Postfix (_mail sender/receiver_)
    * Dovecot (_mail storage/client communication_)
    * Amavisd (_middleware for virus scanning and sender verification [spf/dkim]_)
    * ClamAV (_virus scanner_)
    * SpamAssassin (_spam scanner_)
    * [iRedAPD](https://github.com/iredmail/iRedAPD) (_Postfix policy server_)
    * [mlmmj](http://mlmmj.org/) (_Mailing list management_)
    * [mlmmjadmin](https://github.com/iredmail/mlmmjadmin) (_Mailing list Rest-API_)
    * PHP
    * See 'Default opt-ins'
    * See 'Default opt-outs'


* **Configuration**
  * **Default config**:
    * Data directory: '/var/vmail'
    * Admin user: admin@DOMAIN.TLD
    * Script directory: '/usr/local/sbin/iredmail' (_for managing aliases, dkim keys, ..._)
 

  * **Default opt-ins**:
    * Package installation
      * [ManageSieve](https://wiki1.dovecot.org/ManageSieve)
      * [RoundCube Webmail](https://roundcube.net/)
      * [Fail2Ban](https://www.fail2ban.org)
    * [Postscreen](https://www.postfix.org/POSTSCREEN_README.html)


  * **Default opt-outs**:
    * Package installation
      * [NetData](https://netdata.cloud) (_Monitoring/Troubleshooting Utility_)
      * [SOGo Groupware](https://www.sogo.nu/) (_Webmail/Calendar/Contacts/Client Sync_)
    * NFTables firewall management


## Info

* **Info:** Consider using a **Mail Gateway to gain Security**!

  Per example: [Proxmox Mail Gateway](https://github.com/ansibleguy/sw_proxmox_mail_gw)


* **Note:** this role currently only supports debian-based systems


* **Note:** Most of the role's functionality can be opted in or out.

  For all available options - see the default-config located in the main defaults-file!


* **Warning:** Not every setting/variable you provide will be checked for validity. Bad config might break the role!


* **Note:** After the installation, a configuration dump-file is created!

  In this file you can find the **credentials and useful information** to the services.

  It can be found at:

  - the controller: /tmp/{{ inventory_hostname }}_iRedMail.tips
  - the target system: /var/log/iredadmin/iRedMail.tips


* **Warning:** If 'postscreen' is enabled (_default_) - mail clients need to connect via port 587 instead of 25!


* **Info:** If you want to use mail clients with this server - follow this nice documentation of iRedMail: [LINK](https://docs.iredmail.org/index.html#configure-mail-client-applications)


* **Info:** The installation script's output is saved to '/var/log/iredmail/install_stdout.log'.

  Other logs that are helpful for troubleshooting can also be found there.


* **Info:** You can modify many settings (_exports_) of the installation script.

  Not all make sense or are safe to be changed. => BE WARNED.

  1. You are able to override any basic global variable shown in '[core](https://github.com/iredmail/iRedMail/blob/master/conf/core)' or '[global](https://github.com/iredmail/iRedMail/blob/master/conf/global)' - using the 'iredmail.overrides.settings' dictionary. (_this is supported by the script_)
  2. You can change config inside any file in the '[conf](https://github.com/iredmail/iRedMail/tree/master/conf)' directory - using the 'iredmail.overrides.conf' dictionary. (_this is NOT SUPPORTED by the script_)


* **Info:** You can only configure one domain as further domains can be configured using the iRedAdmin web interface.

  It can be found at: https://SRV.DOMAIN.TLD/iredadmin (_credentials in setup TIPS_)


* **Info:** More advanced configuration like 'aliases' and 'forwarding rules' are not configurable using the web-interface - unless you upgrade to [iRedAdmin PRO](https://www.iredmail.org/pricing.html).

  Therefore, I created some useful scripts to make their management easier.

  You can find them at: '/usr/local/sbin/iredmail'


## Prerequisites

See: [Prerequisites](https://github.com/ansibleguy/sw_iredmail/blob/stable/Prerequisites.md)

## Setup

For this role to work - you must install its dependencies first:

```
ansible-galaxy install -r requirements.yml
```


## Usage

### Config

Define the config as needed:
```yaml
iredmail:
  fqdn: 'srv.template.ansibleguy.net'
  # per example: 'srv.template.ansibleguy.net' must be a valid, public dns-hostname of the server

  manage:
    sogo: true  # install SOGo component

  nginx:  # configure the webserver settings => see: https://github.com/ansibleguy/infra_nginx
    aliases: ['mail.template.ansibleguy.net']  # additional domains to add to the certificate
    ssl:
      mode: 'letsencrypt'  # or selfsigned/ca
      #  if you use 'selfsigned' or 'ca':
      #    cert:
      #      cn: 'iRedMail Server'
      #      org: 'AnsibleGuy'
      #      email: 'iredmail@template.ansibleguy.net'
    letsencrypt:
      email: 'iredmail@template.ansibleguy.net'
```

Bare minimum example:
```yaml
iredmail:
  fqdn: 'srv.template.ansibleguy.net'
```

### Execution

Run the playbook:
```bash
ansible-playbook -K -D -i inventory/hosts.yml playbook.yml
```

There are also some useful **tags** available:
* database
* config
* base
