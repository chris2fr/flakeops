{ config, pkgs, lib, ... }:
let 
in
{ 
  services.caddy = {
    enable = false;
    package = pkgs.caddy.withPlugins {
      plugins = ["github.com/greenpau/caddy-security@v1.1.31"];
      # plugins = ["github.com/greenpau/caddy-security@v1.1.31" "github.com/mholt/caddy-l4@v0.0.0-20251124224044-66170bec9f4d"];
      hash = "sha256-b+hW1MN84eW7OkBIwKHp4VrvHOVi8gsTnTrWAoxmbE0=";
    };
    environmentFile = "/var/lib/caddy/.env";
    user = "wwwrun";
    group = "wwwrun";
    email = "hostmaster@lesgrandsvoisins.com";
    globalConfig = ''
      http_port 84
      https_port 447
      order authenticate before respond
      order authorize before basicauth


	security {
		oauth identity provider keycloak {
			driver generic
			realm master
			client_id {env.KEYCLOAK_CLIENT_ID}
			client_secret {env.KEYCLOAK_CLIENT_SECRET}
			scopes openid email profile
			metadata_url https://key.lesgrandsvoisins.com/realms/master/.well-known/openid-configuration
		}

		authentication portal myportal {
			crypto default token lifetime 3600
			crypto key sign-verify {env.JWT_SHARED_KEY}
			enable identity provider keycloak
			cookie domain cp.roses.gdvoisins.com
			ui {
				links {
					"My Website" https://cp.roses.gdvoisins.com:447/ icon "las la-star"
					"My Identity" "/whoami" icon "las la-user"
				}
			}
			transform user {
				match origin keycloak
				action add role authp/user
			}
		}

		authorization policy mypolicy {
			set auth url https://cp.roses.gdvoisins.com:447/
			allow roles authp/admin authp/user
			crypto key verify {env.JWT_SHARED_KEY}
		}
	}
    '';
    extraConfig = ''

    '';
    virtualHosts = {
      "auth.roses.gdvoisins.com" = {
        extraConfig = ''
          tls /var/lib/acme/auth.roses.gdvoisins.com/fullchain.pem /var/lib/acme/auth.roses.gdvoisins.com/key.pem
          authorize with mypolicy
          respond "auth is running"
        '';
      };
      "fontenay.gdvoisins.com" = {
        extraConfig = ''
          tls /var/lib/acme/fontenay.gdvoisins.com/fullchain.pem /var/lib/acme/fontenay.gdvoisins.com/key.pem
          reverse_proxy https://fontenay.gdvoisins.com:443
        '';
      };
      "roses.gdvoisins.com" = {
        extraConfig = ''
          tls /var/lib/acme/roses.gdvoisins.com/fullchain.pem /var/lib/acme/roses.gdvoisins.com/key.pem
          respond "Hello There Bonjour etc."
        '';
      };
      "cp.roses.gdvoisins.com" = {
        # [mannchri@rosest330:~]$ ls /var/lib/copyparty/ssl-public/
        # ca.key  ca.pem  cfssl.json  srv.key  srv.pem
        extraConfig = ''
          tls /var/lib/acme/cp.roses.gdvoisins.com/fullchain.pem /var/lib/acme/cp.roses.gdvoisins.com/key.pem
          authenticate with myportal
          reverse_proxy https://[::1]:3923 {
            transport http {
              tls_server_name cp.roses.gdvoisins.com
              tls_insecure_skip_verify
            }
          }
        '';
            # transport http {
            #   tls_client_auth /var/lib/copyparty/ssl/srv.pem /var/lib/copyparty/ssl/srv.key
            # }
      };
      "public.cp.roses.gdvoisins.com" = {
        extraConfig = ''
          tls /var/lib/acme/public.cp.roses.gdvoisins.com/fullchain.pem /var/lib/acme/public.cp.roses.gdvoisins.com/key.pem
          reverse_proxy https://[::1]:3924 {
            transport http {
              tls_server_name public.cp.roses.gdvoisins.com
              tls_insecure_skip_verify
            }
          }
        '';
        # {
        #     transport http {
        #       tls_client_auth /var/lib/copyparty/ssl-public/srv.pem /var/lib/copyparty/ssl-public/srv.key
        #     }
        #   }
      };
      "fs.roses.gdvoisins.com" = {
        extraConfig = ''
          tls /var/lib/acme/fs.roses.gdvoisins.com/fullchain.pem /var/lib/acme/fs.roses.gdvoisins.com/key.pem
          respond "fs.roses.gdvoisins.com"
        '';
      };
      "cw.roses.gdvoisins.com" = {
        extraConfig = ''
          tls /var/lib/acme/cw.roses.gdvoisins.com/fullchain.pem /var/lib/acme/cw.roses.gdvoisins.com/key.pem
          respond "cw.roses.gdvoisins.com"
        '';
        };
      "op.roses.gdvoisins.com" = {
        extraConfig = ''
          tls /var/lib/acme/op.roses.gdvoisins.com/fullchain.pem /var/lib/acme/op.roses.gdvoisins.com/key.pem
          respond "op.roses.gdvoisins.com"
        '';
        };
    };
  };
}