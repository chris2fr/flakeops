sudo -u oauth2-proxy /nix/store/nw5fzppysbf6qq9kl792aplvyjw2rpih-oauth2-proxy-7.8.2/bin/oauth2-proxy \
--approval-prompt='force'  \
--client-id='seafile'  \
--client-secret-file='/etc/.secrets/.seafile_oauthproxy_keyfile' \
--code-challenge-method='S256'  \
--cookie-csrf-expire=5m \
--cookie-csrf-per-request='true' \
--cookie-domain='roses.lgv.info'  \
--cookie-expire='168h0m0s' \
--cookie-httponly=false \
--cookie-name='_oauth2_proxy_roses'  \
--cookie-refresh=5m \
--cookie-samesite=none \
--cookie-secret='NgbKPVOqtJn5bipSRGuR22BwasVS1J5u' \
--cookie-secure=false \
--email-domain='*'  \
--http-address='0.0.0.0:8082' \
--https-address=':41443' \
--insecure-oidc-allow-unverified-email='true'  \
--oidc-issuer-url='https://key.lesgrandsvoisins.com/realms/master' \
--pass-access-token=true \
--pass-authorization-header=true \
--pass-host-header=true  \
--provider='keycloak-oidc' \
--proxy-prefix='/oauth2'  \
--redirect-url='https://roses.lgv.info/oauth2/callback' \
--request-logging=true \
--reverse-proxy=true \
--session-store-type=cookie \
--set-authorization-header=true \
--set-xauthrequest=true \
--skip-provider-button=false \
--tls-cert-file='/var/lib/acme/roses.lgv.info/fullchain.pem' \
--tls-key-file='/var/lib/acme/roses.lgv.info/key.pem' \
--upstream='file:///var/www/default'  


#--whitelist-domain='roses.lgv.info' 


# --pass-basic-auth=true \

#--skip-auth-preflight=true 


# --scope="user:email" \