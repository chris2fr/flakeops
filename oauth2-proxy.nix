{ config, pkgs, lib, filestash, ... }:
let 
  # oidcSeafileSecret = import ./secrets/oidc-seafile-secret.nix;
    oidcRosesSecret = import ./secrets/oidc-roses-secret.nix;
    jwtVouchSecret = import ./secrets/jwt-vouch-secret.nix;
in
{

    services.oauth2-proxy = {
      enable = true;

      # # Common configuration
      provider = "keycloak-oidc"; # or "github", "gitlab", "azure", etc.
      email.domains = ["*"]; # restrict to specific email domains
      
      # # Client credentials (register your app with the OAuth provider)
      clientID = "seafile";
      keyFile = "/etc/.secrets/.seafile_oauthproxy_keyfile";
      # # clientSecret = "your-client-secret";
      
      # # Cookie settings
      cookie.secret = "NgbKPVOqtJn5bipSRGuR22BwasVS1J5u"; # generate with: openssl rand -base64 32 | head -c 32 | base64
      cookie.secure = true;
      
      # # Additional settingsenvironment.systemPackages = with pkgs; [
      # # upstream = "http://localhost:1234"; # your backend service
      httpAddress = "127.0.0.1:4180"; # where oauth2-proxy listens
      reverseProxy = true;
      upstream = "http://127.0.0.1:4180";
      # upstream = "file:///var/www/default";
      # tls = {
      #   enable = true;
      #   certificate = "/var/lib/acme/roses.gdvoisins.com/fullchain.pem";
      #   key = "/var/lib/acme/roses.gdvoisins.com/key.pem";
      #   httpsAddress = "roses.gdvoisins.com:41443";
      # };
      redirectURL = "https://op.roses.gdvoisins.com/oauth2/callback";
      oidcIssuerUrl = "https://key.lesgrandsvoisins.com/realms/master";
      loginURL = "https://key.lesgrandsvoisins.com/realms/master/protocol/openid-connect/auth";
      # validateURL = "";
      httpOnly = false;
      # extraConfig = {
      #   approval-prompt="force";
      #   client-id="seafile";
      #   client-secret-file="/etc/.secrets/.seafile_oauthproxy_keyfile";
      #   code-challenge-method="S256";
      #   cookie-csrf-expire="5m";
      #   cookie-csrf-per-request="true";
      #   cookie-domain="roses.gdvoisins.com";
      #   cookie-expire="168h0m0s";
      #   cookie-httponly="false";
      #   cookie-name="_oauth2_proxy_roses";
      #   cookie-refresh="5m";
      #   cookie-samesite="none";
      #   cookie-secret="NgbKPVOqtJn5bipSRGuR22BwasVS1J5u";
      #   cookie-secure="false";
      #   email-domain="*" ;
      #   http-address=":4180";
      #   https-address=":41443";
      #   insecure-oidc-allow-unverified-email="true" ;
      #   oidc-issuer-url="https://key.lesgrandsvoisins.com/realms/master";
      #   pass-access-token="true";
      #   pass-authorization-header="true";
      #   pass-host-header="true" ;
      #   provider="keycloak-oidc";
      #   proxy-prefix="/oauth2" ;
      #   redirect-url="https://roses.gdvoisins.com/oauth2/callback";
      #   request-logging="true";
      #   reverse-proxy="true";
      #   session-store-type="cookie";
      #   set-authorization-header="true";
      #   set-xauthrequest="true";
      #   skip-provider-button="false";
      #   tls-cert-file="/var/lib/acme/roses.gdvoisins.com/full.pem";
      #   tls-key-file="/var/lib/acme/roses.gdvoisins.com/key.pem";
      #   upstream="file:///var/www/default";
      # };
    };

}