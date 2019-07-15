# Certbot / Nginx / Docker

### What’s Certbot?

Certbot is a free, open source software tool for automatically using [Let’s Encrypt](https://letsencrypt.org/) certificate on manually-administrated websites to enable HTTPS.

Certbot is made by the [Electronic Frontier Foundation (EFF)](https://www.eff.org/), a 501(c)3 nonprofit based in San Francisco, CA, that defends digital privacy, free speech, and innovation.

This project uses the `--webroot` method of [certificate issuance](https://certbot.eff.org/docs/using.html#webroot).

![Screen Shot 2019-07-10 at 10 01 02 AM](https://user-images.githubusercontent.com/5332509/61080925-161f2b80-a3f4-11e9-9e8b-51022503eccc.png)

**NOTE**: All included scripts are runnable by non-sudo users (assuming the user is in the `docker` group). The generated output files will however be owned by the `root` user, and as such would require `sudo` level rights to move or manipulate.

## TL;DR

Assumes that Docker is installed, and that you have `sudo` rights on the machine you wish to install certificate on.

### Generate initial certificate

Update the `.env` file, then run:

```
./letsencrypt-init.sh
```

and follow the prompts

### Renew existing certificate

Update the `.env` file, then run:

```
./letsencrypt-renew.sh
```
and follow the prompts

## Detailed Overview

### Configuration file: `.env`

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

### Generate initial certificate script: `letsencrypt-init.sh`

This script should be used when first acquiring your initial Let's Encrypt certificate.

Update the `.env` file to suit your environment. It is recommended to start with `STAGING=1` (example using hostname [dp-dev-1.cyberimpact.us]())

First dry-run with `STAGING=1`:

```console
$ ./letsencrypt-init.sh
INFO: source environment variables

### Starting nginx ...
d9000f9f1af5d9c7dd39c4f4d8a35ead08065164201850d59771f428c83de86e
2019/07/15 14:23:48 [notice] 8#8: signal process started

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

On success, run with `STAGING=0` and follow the prompts:

```console
$ ./letsencrypt-init.sh
INFO: source environment variables
Existing data found for dp-dev-1.cyberimpact.us ... Continue and replace existing certificate? (y/N) y

### Starting nginx ...
c01e43258b2ba667548b4c2854bb855e6d0d126e835678b8e8b15748ee0ae46c
2019/07/15 14:24:47 [notice] 8#8: signal process started

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
   Your cert will expire on 2019-10-13. To obtain a new or tweaked
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
2019/07/15 14:25:05 [notice] 15#15: signal process started
depth=2 O = Digital Signature Trust Co., CN = DST Root CA X3
verify return:1
depth=1 C = US, O = Let's Encrypt, CN = Let's Encrypt Authority X3
verify return:1
depth=0 CN = dp-dev-1.cyberimpact.us
verify return:1
DONE
2019/07/15 14:25:09 [notice] 22#22: signal process started

### Naviage to https://dp-dev-1.cyberimpact.us and verify that your certificate has been installed ...

Press enter when finished ...
nginx
nginx
```

After a successful issuance of certificate the user should observe a page similar to the following:

![certificate validation](https://user-images.githubusercontent.com/5332509/61223736-42d08d00-a6eb-11e9-9215-26dea86b6d08.png)

And if you shared your email address with the Electronic Frontier
Foundation, you'd receive an email similar to:

![eff email](https://user-images.githubusercontent.com/5332509/61223751-49f79b00-a6eb-11e9-9112-db69ac225da1.png)

### Renew existing certificate script: `letsencrypt-renew.sh`

This script should be used when renewing your existing Let's Encrypt certificate.

Update the `.env` file to suit your environment (example using hostname [dp-dev-1.cyberimpact.us]())

```console
$ ./letsencrypt-renew.sh
INFO: source environment variables

### Starting nginx ...
dc87387bd8d15c687961f6fb4e4bf145a7a7b6e03119ae25bc6593073806ab81
2019/07/15 14:30:57 [notice] 8#8: signal process started

### Requesting Let's Encrypt certificate renewal for dp-dev-1.cyberimpact.us ...
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Processing /etc/letsencrypt/renewal/dp-dev-1.cyberimpact.us.conf
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Cert not yet due for renewal

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

The following certs are not due for renewal yet:
  /etc/letsencrypt/live/dp-dev-1.cyberimpact.us/fullchain.pem expires on 2019-10-13 (skipped)
No renewals were attempted.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

### Reloading nginx ...
2019/07/15 14:31:02 [notice] 15#15: signal process started
depth=2 O = Digital Signature Trust Co., CN = DST Root CA X3
verify return:1
depth=1 C = US, O = Let's Encrypt, CN = Let's Encrypt Authority X3
verify return:1
depth=0 CN = dp-dev-1.cyberimpact.us
verify return:1
DONE
2019/07/15 14:31:06 [notice] 22#22: signal process started

### Naviage to https://dp-dev-1.cyberimpact.us and verify that your certificate has been installed ...

Press enter when finished ...
nginx
nginx
```

### Renew existing certificate script (alternate): `letsencrypt-renew-alt.sh`

This script should be used when renewing your existing Let's Encrypt certificate and the well-known endpoint is already exposed via the web server.

Only the `certbot` container is run so that certificate can be updated without having to stop/start the web server.

```console
$ ./letsencrypt-renew-alt.sh
INFO: source environment variables

Assumes that the well-known endpoint is already exposed for dp-dev-1.cyberimpact.us ... Continue? (y/N) y

### Requesting Let's Encrypt certificate renewal for dp-dev-1.cyberimpact.us ...
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Processing /etc/letsencrypt/renewal/dp-dev-1.cyberimpact.us.conf
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Cert not yet due for renewal

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

The following certs are not due for renewal yet:
  /etc/letsencrypt/live/dp-dev-1.cyberimpact.us/fullchain.pem expires on 2019-10-13 (skipped)
No renewals were attempted.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

## Certificate files

Certbot will create a number of files, including your certificate in the directory defined by the `$CERTS` variable. Many of these files will be owned by the `root` user, and care should be taken as their order is important for Cerbot when renewing your certificate.

Example from [dp-dev-1.cyberimpact.us](): `/home/username/certbot/certs`

```console
$ ls -alh certs/
...
drwx------ 3 root         root              41 Jul 11 15:44 accounts
drwx------ 3 root         root              36 Jul 11 15:44 archive
drwxr-xr-x 2 root         root              33 Jul 11 15:44 csr
drwx------ 2 root         root              33 Jul 11 15:44 keys
drwx------ 3 root         root              49 Jul 11 15:44 live
drwxr-xr-x 2 root         root              41 Jul 11 15:44 renewal
drwxr-xr-x 5 root         root              40 Jul 11 15:44 renewal-hooks
```

```console
$ tree certs/
certs/
├── accounts
│   └── acme-v02.api.letsencrypt.org
│       └── directory
│           └── cad102059f982a03619d6ba2b3f237de
│               ├── meta.json
│               ├── private_key.json
│               └── regr.json
├── archive
│   └── dp-dev-1.cyberimpact.us
│       ├── cert1.pem
│       ├── chain1.pem
│       ├── fullchain1.pem
│       └── privkey1.pem
├── csr
│   └── 0000_csr-certbot.pem
├── keys
│   └── 0000_key-certbot.pem
├── live
│   ├── dp-dev-1.cyberimpact.us
│   │   ├── cert.pem -> ../../archive/dp-dev-1.cyberimpact.us/cert1.pem
│   │   ├── chain.pem -> ../../archive/dp-dev-1.cyberimpact.us/chain1.pem
│   │   ├── fullchain.pem -> ../../archive/dp-dev-1.cyberimpact.us/fullchain1.pem
│   │   ├── privkey.pem -> ../../archive/dp-dev-1.cyberimpact.us/privkey1.pem
│   │   └── README
│   └── README
├── renewal
│   └── dp-dev-1.cyberimpact.us.conf
└── renewal-hooks
    ├── deploy
    ├── post
    └── pre

15 directories, 16 files
```

### References

- Certbot: [https://certbot.eff.org](https://certbot.eff.org)
- Nginx: [https://www.nginx.com](https://www.nginx.com)
- Docker: [https://www.docker.com](https://www.docker.com)

