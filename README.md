# Certbot / Nginx / Docker

### What’s Certbot?

Certbot is a free, open source software tool for automatically using [Let’s Encrypt](https://letsencrypt.org/) certificates on manually-administrated websites to enable HTTPS.

Certbot is made by the [Electronic Frontier Foundation (EFF)](https://www.eff.org/), a 501(c)3 nonprofit based in San Francisco, CA, that defends digital privacy, free speech, and innovation.

This project uses the `--webroot` method of [certificate issuance](https://certbot.eff.org/docs/using.html#webroot).

![Screen Shot 2019-07-10 at 10 01 02 AM](https://user-images.githubusercontent.com/5332509/61080925-161f2b80-a3f4-11e9-9e8b-51022503eccc.png)

## TL;DR

Assumes that Docker is installed, and that you have `sudo` rights on the machine you wish to install certificates on.

### Initialize

Update the `.env` file, then run:

```
./letsencrypt-init.sh
```

### Renew

Update the `.env` file, then run:

```
./letsencrypt-renew.sh
```

## Detailed Overview

### file: `.env`

Example values are provided, but the `.env` file should be updated to match your host and configuration requirements.

```bash
# Environment variable declaration

# Domain(s) you wish to get a certificate for
DOMAINS=(example.org www.example.org)

# RSA key size
RSA_KEY_SIZE=4096

# Adding a valid address is strongly recommended
EMAIL=''

# Staging a dry-run - enabled = 1, disabled = 0 (ref: https://letsencrypt.org/docs/staging-environment/)
STAGING=1

# Volumes on host denoted as full path
# Path to certificate and chain, key file and certbot maintenance files
CERTS=/home/username/certbot/certs
# Path to http-01 challenge files
CERTS_DATA=/home/username/certbot/data

# SELinux - enforced = 1, disabled = 0
SELINUX=0

# Ports for http and https
HTTP_PORT=80
HTTPS_PORT=443
```

**NOTE**: it is recommended to start with `STAGING=1` until you receive the success message (see below) as too many failed attempts can get you blocked.

```console
...
IMPORTANT NOTES:
 - The dry run was successful.
 - Your account credentials have been saved in your Certbot
   configuration directory at /etc/letsencrypt. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Certbot so
   making regular backups of this folder is ideal.
```

### script: `letsencrypt-init.sh`

This script should be used when first acquiring your Let's Encrypt certificates.

Update the `.env` file to suit your environment. It is recommended to start with `STAGING=1` (example using hostname [dp-dev-1.cyberimpact.us]())

`STAGING=1`:

```console
$ ./letsencrypt-init.sh
INFO: source environment variables

### Starting nginx ...
b2cbb048627a405c612f16241bcbf48c235c8b9bf8323d45560d3751b47fd9c8
2019/07/11 19:00:55 [notice] 8#8: signal process started

### Requesting Let's Encrypt certificate for dp-dev-1.cyberimpact.us ...
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator webroot, Installer None
Obtaining a new certificate
Performing the following challenges:
http-01 challenge for dp-dev-1.cyberimpact.us
Using the webroot path /data/letsencrypt for all unmatched domains.
Waiting for verification...
Cleaning up challenges

IMPORTANT NOTES:
 - The dry run was successful.
 - Your account credentials have been saved in your Certbot
   configuration directory at /etc/letsencrypt. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Certbot so
   making regular backups of this folder is ideal.
nginx
nginx
```

`STAGING=0`: Follow the prompts

```console
$ ./letsencrypt-init.sh
INFO: source environment variables
Existing data found for dp-dev-1.cyberimpact.us ... Continue and replace existing certificate? (y/N) y

### Starting nginx ...
be60e67f7b5946bc2a51b9785a80587bb98e2240bb01c0ee1da95a4f2af94b7f
2019/07/11 19:44:09 [notice] 8#8: signal process started

### Requesting Let's Encrypt certificate for dp-dev-1.cyberimpact.us ...
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator webroot, Installer None

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing to share your email address with the Electronic Frontier
Foundation, a founding partner of the Let's Encrypt project and the non-profit
organization that develops Certbot? We'd like to send you email about our work
encrypting the web, EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: y
Obtaining a new certificate
Performing the following challenges:
http-01 challenge for dp-dev-1.cyberimpact.us
Using the webroot path /data/letsencrypt for all unmatched domains.
Waiting for verification...
Cleaning up challenges

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/dp-dev-1.cyberimpact.us/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/dp-dev-1.cyberimpact.us/privkey.pem
   Your cert will expire on 2019-10-09. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot
   again. To non-interactively renew *all* of your certificates, run
   "certbot renew"
 - Your account credentials have been saved in your Certbot
   configuration directory at /etc/letsencrypt. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Certbot so
   making regular backups of this folder is ideal.
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le


### Reloading nginx ...
2019/07/11 19:44:28 [notice] 15#15: signal process started
depth=2 O = Digital Signature Trust Co., CN = DST Root CA X3
verify return:1
depth=1 C = US, O = Let's Encrypt, CN = Let's Encrypt Authority X3
verify return:1
depth=0 CN = dp-dev-1.cyberimpact.us
verify return:1
DONE
2019/07/11 19:44:32 [notice] 22#22: signal process started

### Naviage to https://dp-dev-1.cyberimpact.us and verify that your certificate has been installed ...

Press enter when finished ...
nginx
nginx
```

On a successful issuance the user should observe a page similar to the following:

<img width="80%" alt="Validate Certificate" src="https://user-images.githubusercontent.com/5332509/61080926-161f2b80-a3f4-11e9-9e80-0717a1bc7f8a.png">

Along with a valid certificate:

<img width="50%" alt="Validate Certificate" src="https://user-images.githubusercontent.com/5332509/61080927-161f2b80-a3f4-11e9-8d7a-f3fccd6ba376.png">

### script: `letsencrypt-renew.sh`

This script should be used when renewing your Let's Encrypt certificates.

Update the `.env` file to suit your environment (example using hostname [dp-dev-1.cyberimpact.us]())

```console
$ ./letsencrypt-renew.sh
INFO: source environment variables

### Starting nginx ...
b7458fea83d268a542f24ad79bde0efc4fa2e7ebd61af7bd4d7b584a22362f13
2019/07/11 19:47:55 [notice] 8#8: signal process started

### Requesting Let's Encrypt certificate renewal for dp-dev-1.cyberimpact.us ...
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Processing /etc/letsencrypt/renewal/dp-dev-1.cyberimpact.us.conf
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Cert not yet due for renewal

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

The following certs are not due for renewal yet:
  /etc/letsencrypt/live/dp-dev-1.cyberimpact.us/fullchain.pem expires on 2019-10-09 (skipped)
No renewals were attempted.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

### Reloading nginx ...
2019/07/11 19:48:00 [notice] 15#15: signal process started
depth=2 O = Digital Signature Trust Co., CN = DST Root CA X3
verify return:1
depth=1 C = US, O = Let's Encrypt, CN = Let's Encrypt Authority X3
verify return:1
depth=0 CN = dp-dev-1.cyberimpact.us
verify return:1
DONE
2019/07/11 19:48:04 [notice] 22#22: signal process started

### Naviage to https://dp-dev-1.cyberimpact.us and verify that your certificate has been installed ...

Press enter when finished ...
nginx
nginx
```

### script: `letsencrypt-renew-alt.sh`

This script should be used when renewing your Let's Encrypt certificates and the well-known endpoint is already exposed via the existing web server.

Only the `certbot` container is run so that certificates can be updated without having to stop/start the web server.

### References

- Certbot: [https://certbot.eff.org](https://certbot.eff.org)
- Nginx: [https://www.nginx.com](https://www.nginx.com)
- Docker: [https://www.docker.com](https://www.docker.com)
