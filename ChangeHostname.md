# Notes to changing the hostname

1. Make sure to set all public dns records to their new values. 

   If you are using LetsEncrypt - you may want to wait a minimum of 30min before running the playbook.

   Else the certbot might fail to get your new DNS record!

2. Files to update your hostname/admin-mail in:
```bash
# hostname
/etc/amavis/conf.d/50-user  # don't forget dkim settings
/etc/aliases
/etc/postfix/main.cf
/opt/iRedAPD-5.0.4/settings.py
# rename file
/var/lib/dkim/DOMAIN.TLD.pem
# mail
/opt/www/iRedAdmin-1.7/settings.py
/etc/postfix/main.cf
```

3. Re-run the playbook

4. Reboot

5. Re-generate aliases

```bash
postalias /etc/aliases
postalias /etc/postfix/aliases
systemctl restart postfix@-.service postfix.service
```
