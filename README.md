[![iRedMail](https://www.iredmail.org/assets/images/logo-iredmail.png)](https://www.iredmail.org/)

# Ansible Role - iRedMail

Role to deploy iRedMail mail servers.

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
    * Dovecot (_mail receiver_)
    * Postfix (_mail sender_)
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
    * Script directory: '/usr/local/sbin/iredmail' (_for adding aliases, ..._)
 

  * **Default opt-ins**:
    * Package installation
      * [ManageSieve](https://wiki1.dovecot.org/ManageSieve)
      * [RoundCube Webmail](https://roundcube.net/)
      * [Fail2Ban](https://www.fail2ban.org)
    * [Postscreen](https://www.postfix.org/POSTSCREEN_README.html)


  * **Default opt-outs**:
    * Package installation
      * [NetData](https://netdata.cloud) (_Monitoring/Troubleshooting Utility_)
      * [SOGo Groupware](https://www.sogo.nu/) **WARNING: Installation fails currently - therefore not an option** 
    * NFTables firewall management


## Info

* **Note:** this role currently only supports debian-based systems


* **Note:** Most of this functionality can be opted in or out using the main defaults file and variables!


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

  1. You are able to override any basic global variable shown in '[core](https://github.com/iredmail/iRedMail/blob/master/conf/core)' or '[global](https://github.com/iredmail/iRedMail/blob/master/conf/global)' - using the 'iredmail.setting_overrides' dictionary. (_this is supported by the script_)
  2. You can change config inside any file in the '[conf](https://github.com/iredmail/iRedMail/tree/master/conf)' directory - using the 'iredmail.custom_overrides' dictionary. (_this is NOT SUPPORTED by the script_)


* **Info:** You can only configure one domain as further domains can be configured using the iRedAdmin web interface.

  It can be found at: https://SRV.DOMAIN.TLD/iredadmin (_credentials in setup TIPS_)


* **Info:** More advanced configuration like 'aliases' and 'forwarding rules' are not configurable using the web-interface - unless you upgrade to [iRedAdmin PRO](https://www.iredmail.org/pricing.html).

  Therefore, I created some useful scripts to make their management easier.

  You can find them at: '/usr/local/sbin/iredmail'


## Prerequisite


### System requirements

Make sure your target system meets the [system requirements](https://docs.iredmail.org/install.iredmail.on.debian.ubuntu.html)!

  - At LEAST 4GB of RAM for a low traffic setup.
  - The target system needs to have a public IP.
  - You need to have a public Domain.
  - You might want to create a dedicated volume (_maybe use LVM_) for the data-directory - so you can easier extend/manage it.

### Firewalling

For the server to work, you must allow the following ports using your firewall:

  - For web access: 80, 443 (_443 can be GeoIP/sourceIP restricted, 80 needs to be open if you are using LetsEncrypt_)
  - Mailing basic: 25, 587, 465
  - POP/IMAP over SSL: 993, 995
  - POP/IMAP with StartTLS: 110, 143


### Public DNS

You need to configure public DNS records for mailing to work.

iRedMail has a nice documentation on how to do that: [LINK](https://docs.iredmail.org/setup.dns.html)

**Needed**:

| TYPE | KEY                             | VALUE                                          | COMMENT                                                                                  |
|:----:|:--------------------------------|:-----------------------------------------------|:-----------------------------------------------------------------------------------------|
|  A   |  SRV.DOMAIN.TLD                 | SRV-PUBLIC-IP                                  | -                                                                                        |
|  MX  | DOMAIN.TLD                 | 10 SRV.DOMAIN.TLD                              | -                                                                                        |
| TXT  | DOMAIN.TLD                 | v=spf1 mx -all                                 | -                                                                                        |
| TXT  | _dmarc.DOMAIN.TLD          | v=DMARC1; p=quarantine; aspf=s; adkim=s;       | -                                                                                        |
| TXT  | mail._domainkey.DOMAIN.TLD | v=DKIM1; p=MIIBIjANBgkqhkiG...                 | Replace the value by YOUR DKIM record!                                                   |
| TXT  | *.DOMAIN.TLD               | v=spf1 -all                                    | Any domain/subdomain that is not used to send mails, should IMPLICITLY DENY any senders! |
| PTR  | YOUR-SRV-IP | SRV.DOMAIN.TLD | You cannot set a PTR record in your DNS-Panel/management! Your internet provider/hoster has to do that. Bigger hosters will give you an option for this in their managment interface. |

**Optional**:

| TYPE | KEY                         | VALUE                                       | COMMENT                                                                                  |
|:----:|:----------------------------|:--------------------------------------------|:-----------------------------------------------------------------------------------------|
|  CNAME | PRETTY_NAME.DOMAIN.TLD      | SRV.DOMAIN.TLD                              | Just a pretty name for the webmail if your server-name isn't that nice |
|  CNAME | autodiscover.DOMAIN.TLD     | SRV.DOMAIN.TLD                      | If you use a mail-client (_outlook_) |
|  CNAME | autoconfig.DOMAIN.TLD       | SRV.DOMAIN.TLD                      | If you use a mail-client (_kmail, ..._) |


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

  nginx:  # configure the webserver settings => see: https://github.com/ansibleguy/infra_nginx
    aliases: ['mail.ansibleguy.net']  # additional domains to add to the certificate
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

### Execution

Run the playbook:
```bash
ansible-playbook -K -D -i inventory/hosts.yml playbook.yml
```

There are also some useful **tags** available:
* database
* config
* base
