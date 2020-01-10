#!/usr/bin/env bash

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

# Nginx config file for using Let's Encrypt
_lets_encrypt_conf () {
  local OUTFILE=./lets_encrypt.conf
  cat > $OUTFILE <<EOF
server {
    listen      ${HTTP_PORT};
    listen [::]:${HTTP_PORT};
    server_name ${DOMAINS[0]};
    location / {
        rewrite ^ https://\$host\$request_uri? permanent;
    }
    location ^~ /.well-known {
        allow all;
        root /data/letsencrypt/;
    }
}
EOF
}

# Nginx config file for validating certificate
_validate_cert_conf() {
    local OUTFILE=./lets_encrypt.conf
  cat > $OUTFILE <<EOF
server {
    listen      ${HTTPS_PORT} ssl;
    listen [::]:${HTTPS_PORT} ssl;
    server_name ${DOMAINS[0]};

    ssl_certificate           /etc/letsencrypt/live/${DOMAINS[0]}/fullchain.pem;
    ssl_certificate_key       /etc/letsencrypt/live/${DOMAINS[0]}/privkey.pem;
    ssl_trusted_certificate   /etc/letsencrypt/live/${DOMAINS[0]}/chain.pem;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
}
EOF
    docker cp ./lets_encrypt.conf nginx-certbot:/etc/nginx/conf.d/default.conf
    docker exec nginx-certbot /usr/sbin/nginx -s reload
    rm -f ./lets_encrypt.conf
    sleep 3s
    OUTFILE=./validate.html
    cat > ${OUTFILE} <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Validate Certificate</title>
</head>
<body>
<h2>Validate Certificate</h2>
<b>Results of</b>: <code>openssl s_client -connect ${DOMAINS[0]}:${HTTPS_PORT}</code>
<pre>
<embed style="width: 100%; height: 2000px" src="openssl-info.txt">
</pre>
</body>
</html>
EOF
    echo "Q" | openssl s_client -connect ${DOMAINS[0]}:${HTTPS_PORT} > ./openssl-info.txt
    docker cp validate.html nginx-certbot:/usr/share/nginx/html/index.html
    docker cp openssl-info.txt nginx-certbot:/usr/share/nginx/html/
}

### Main ###
if [[ -f .env ]]; then
  echo "INFO: source environment variables"
  source .env
else
    echo "ERROR: Could not find the .env file?"
    exit 1;
fi

if [[ -d "${CERTS}" ]]; then
    read -p "Existing data found for ${DOMAINS[0]} ... Continue and replace existing certificate? (y/N) " decision
    if [[ "$decision" == "Y" ]] && [[ "$decision" == "y" ]]; then
        exit;
    fi
    if [[ ! -d "${CERTS_DATA}" ]]; then
        mkdir -p ${CERTS_DATA}
    fi
else
    mkdir -p ${CERTS} ${CERTS_DATA}
fi

echo
echo "### Starting nginx ..."
_lets_encrypt_conf
if [[ ${SELINUX} == "1" ]]; then
    docker run -d --name nginx-certbot \
        --publish ${HTTP_PORT}:${HTTP_PORT} \
        --publish ${HTTPS_PORT}:${HTTPS_PORT} \
        --volume ${CERTS:-./certs}:/etc/letsencrypt:z,ro \
        --volume ${CERTS_DATA:-./certs-data}:/data/letsencrypt:z,rw \
        nginx:alpine
else
    docker run -d --name nginx-certbot \
        --publish ${HTTP_PORT}:${HTTP_PORT} \
        --publish ${HTTPS_PORT}:${HTTPS_PORT} \
        --volume ${CERTS:-./certs}:/etc/letsencrypt \
        --volume ${CERTS_DATA:-./certs-data}:/data/letsencrypt \
        nginx:alpine
fi
sleep 3s
docker cp ./lets_encrypt.conf nginx-certbot:/etc/nginx/conf.d/default.conf
docker exec nginx-certbot /usr/sbin/nginx -s reload
rm -f ./lets_encrypt.conf
sleep 3s

echo
echo "### Requesting Let's Encrypt certificate for ${DOMAINS[0]} ..."
#Join $domains to -d args
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
        certonly \
        --webroot --webroot-path=/data/letsencrypt \
        ${staging_arg} \
        ${email_arg} \
        ${domain_args} \
        --rsa-key-size ${RSA_KEY_SIZE} \
        --agree-tos \
        --http-01-port ${HTTP_PORT} \
        --https-port ${HTTPS_PORT}
else
    docker run -it --rm \
        -v ${CERTS}:/etc/letsencrypt \
        -v ${CERTS_DATA}:/data/letsencrypt \
        certbot/certbot \
        certonly \
        --webroot --webroot-path=/data/letsencrypt \
        ${staging_arg} \
        ${email_arg} \
        ${domain_args} \
        --rsa-key-size ${RSA_KEY_SIZE} \
        --agree-tos \
        --http-01-port ${HTTP_PORT} \
        --https-port ${HTTPS_PORT}
fi

if [[ ${STAGING} != "1" ]]; then
    echo
    echo "### Reloading nginx ..."
    _validate_cert_conf
    docker exec nginx-certbot nginx -s reload
    echo
    echo "### Navigate to https://${DOMAINS[0]} and verify that your certificate has been installed ..."
    echo
    read -p "Press enter when finished ..."
    rm -f validate.html openssl-info.txt
fi

docker stop nginx-certbot
docker rm -fv nginx-certbot
rm -rf ${CERTS_DATA}
exit 0;