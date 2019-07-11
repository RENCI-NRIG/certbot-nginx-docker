#!/usr/bin/env bash
### NOTE: Assumes that the well-known endpoint is already exposed via the web server ###

# Certbot usage: https://certbot.eff.org/docs/man/certbot.html

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

### Main ###
if [[ -f .env ]]; then
  echo "INFO: source environment variables"
  source .env
else
    echo "ERROR: Could not find the .env file?"
    exit 1;
fi

echo
read -p "Assumes that the well-known endpoint is already exposed for ${DOMAINS[0]} ... Continue? (y/N) " decision
if [[ "$decision" != "Y" ]] && [[ "$decision" != "y" ]]; then
    echo "### Exiting ..."
    exit 0;
fi

if [[ ! -d "${CERTS}" ]]; then
    echo "No existing data found for ${DOMAINS[0]} ... Exiting"
    exit 1;
else
    mkdir -p ${CERTS_DATA}
fi

echo
echo "### Requesting Let's Encrypt certificate renewal for ${DOMAINS[0]} ..."
# Join $DOMAINS to -d args
domain_args=""
for domain in "${DOMAINS[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "${EMAIL}" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email ${EMAIL}" ;;
esac

# Enable staging mode if needed
if [[ ${STAGING} == "1" ]]; then staging_arg="--dry-run"; fi
if [[ ${SELINUX} == "1" ]]; then
    docker run -it --rm \
        -v ${CERTS}:/etc/letsencrypt:z,rw \
        -v ${CERTS_DATA}:/data/letsencrypt:z,rw \
        certbot/certbot \
        renew \
        --webroot --webroot-path=/data/letsencrypt \
        ${staging_arg} \
        --rsa-key-size ${RSA_KEY_SIZE} \
        --http-01-port ${HTTP_PORT} \
        --https-port ${HTTPS_PORT}
else
    docker run -it --rm \
        -v ${CERTS}:/etc/letsencrypt \
        -v ${CERTS_DATA}:/data/letsencrypt \
        certbot/certbot \
        renew \
        --webroot --webroot-path=/data/letsencrypt \
        ${staging_arg} \
        --rsa-key-size ${RSA_KEY_SIZE} \
        --http-01-port ${HTTP_PORT} \
        --https-port ${HTTPS_PORT}
fi

rm -rf ${CERTS_DATA}
exit 0;