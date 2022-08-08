[![iRedMail](https://www.iredmail.org/assets/images/logo-iredmail.png)](https://www.iredmail.org/)

# Ansible Role - iRedMail

WARNING: THIS ROLE IS NOT YET IN A STABLE STATE!!

Role to deploy iRedMail mail servers.

You can find the OpenSource Repository to the software here: [REPO](https://github.com/iredmail/iRedMail/)

The installation script used by the repository is installing  

# REPLACE: GALAXY_ID & ROLE

[![Ansible Galaxy](https://img.shields.io/ansible/role/GALAXY_ID)](https://galaxy.ansible.com/ansibleguy/ROLE)
[![Ansible Galaxy Downloads](https://img.shields.io/badge/dynamic/json?color=blueviolet&label=Galaxy%20Downloads&query=%24.download_count&url=https%3A%2F%2Fgalaxy.ansible.com%2Fapi%2Fv1%2Froles%2FGALAXY_ID%2F%3Fformat%3Djson)](https://galaxy.ansible.com/ansibleguy/ROLE)


**Tested:**
* Debian 11

## Functionality

* **Package installation**
  * Ansible dependencies (_minimal_)
  * MariaDB => using [THIS Role](https://github.com/ansibleguy/infra_mariadb)
  * iRedMail Setup Script
    * Dovecot (_mail receiver_)
    * Postfix (_mail sender_)
    * Amavisd (_middleware for virus scanning_)
    * ClamAV (_virus scanner_)
    * [iRedAPD](https://github.com/iredmail/iRedAPD) (_Postfix policy server_)
    * [mlmmj](http://mlmmj.org/) (_Mailing list management_)
    * [mlmmjadmin](https://github.com/iredmail/mlmmjadmin) (_Mailing list Rest-API_)
    * See 'Default opt-ins'
    * See 'Default opt-outs'

  

* **Configuration**
  * tbc


  * **Default config**:
    * Data directory: '/var/vmail'
    * Local backups are created at: '/var/backups'
 

  * **Default opt-ins**:
    * Package installation
      * [SOGo Groupware](https://www.sogo.nu/)
      * [ManageSieve](https://wiki1.dovecot.org/ManageSieve)
      * [RoundCube Webmail](https://roundcube.net/)
      * [Fail2Ban](https://www.fail2ban.org)
    * [Postscreen](https://www.postfix.org/POSTSCREEN_README.html)


  * **Default opt-outs**:
    * Package installation
      * [NetData](https://netdata.cloud) (_Monitoring/Troubleshooting Utility_)
    * NFTables firewall management
    * PHP


## Info

* **Note:** this role currently only supports debian-based systems


* **Note:** Most of this functionality can be opted in or out using the main defaults file and variables!


* **Warning:** Not every setting/variable you provide will be checked for validity. Bad config might break the role!


* **Warning:** Make sure your target system meets the [system requirements](https://docs.iredmail.org/install.iredmail.on.debian.ubuntu.html)!

  At LEAST 4GB of RAM for a low traffic setup.


* **Warning:** You might want to create a dedicated volume (_maybe use LVM_) for the data-directory - so you can easier extend/manage it.


* **Warning:** For the server to work, you must allow the following ports using your firewall:

  For web access: 80, 443

  Mailing basic: 25, 587, 465

  POP/IMAP over SSL: 993, 995

  POP/IMAP with StartTLS: 110, 143


* **Warning:** If 'postscreen' is enabled (_default_) - mail clients need to connect via port 587 instead of 25!


* **Info:** You need to configure public DNS records for mailing to work. iRedMail has a nice documentation on how to do that: [LINK](https://docs.iredmail.org/setup.dns.html)


* **Info:** If you want to use mail clients with this server - follow this nice documentation of iRedMail: [LINK](https://docs.iredmail.org/index.html#configure-mail-client-applications)


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
  domain: 'template.ansibleguy.net'
  mailserver_sub_domain: 'mail'

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
