{ config, pkgs, lib, ... }:
let 
in
{ 
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = ["github.com/greenpau/caddy-security@v1.1.31"];
      # plugins = ["github.com/greenpau/caddy-security@v1.1.31" "github.com/mholt/caddy-l4@v0.0.0-20251124224044-66170bec9f4d"];
      hash = "sha256-b+hW1MN84eW7OkBIwKHp4VrvHOVi8gsTnTrWAoxmbE0=";
    };
    environmentFile = "/var/lib/caddy/.env";
    # user = "wwwrun";
    # group = "wwwrun";
      # http_port 84
      # https_port 443
    email = "hostmaster@lesgrandsvoisins.com";
    	# 		transform user {
			# 	match origin keycloak
			# 	action add role authp/user
			# }
    globalConfig = ''

    order authenticate before respond
    order authorize before basicauth

	security {
		oauth identity provider keycloak {
			driver generic
      realm keycloak
			client_id {env.KEYCLOAK_CLIENT_ID}
			client_secret {env.KEYCLOAK_CLIENT_SECRET}
			scopes openid email profile
			metadata_url https://key.lesgrandsvoisins.com/realms/master/.well-known/openid-configuration
		}

    saml identity provider samlkey {
        driver generic
        realm keycloak
        idp_metadata_location https://key.lesgrandsvoisins.com/realms/master/protocol/saml/descriptor
        application_name "Key LesGrandsVoisins com"
        acs_url https://saml.roses.gdvoisins.com
        application_id "samlcopyparty"
        
      }

		authentication portal samlportal {
			crypto default token lifetime 3600
			crypto key sign-verify {env.JWT_SHARED_KEY}
			enable identity provider keycloak
			cookie domain gdvoisins.com
			ui {
				links {
					"Copyparty" https://not.roses.gdvoisins.com:443/ icon "las la-star"
					"Moi" "/whoami" icon "las la-user"
				}    		
			}
      transform user {
				action add role authp/user
			}

		}

		authentication portal myportal {
			crypto default token lifetime 3600
			crypto key sign-verify {env.JWT_SHARED_KEY}
			enable identity provider keycloak
			cookie domain gdvoisins.com
			ui {
				links {
					"Copyparty" https://not.roses.gdvoisins.com:443/ icon "las la-star"
					"Moi" "/whoami" icon "las la-user"
				}
			}

      transform user {
				action add role authp/user
			}
		}

		authorization policy samlidentified {
			set auth url https://saml.roses.gdvoisins.com:443/
			allow roles guest authp/admin authp/user
			crypto key verify {env.JWT_SHARED_KEY}
		}


		authorization policy identified {
			set auth url https://auth.roses.gdvoisins.com:443/
			allow roles guest authp/admin authp/user
			crypto key verify {env.JWT_SHARED_KEY}
		}

		authorization policy mypolicy {
			set auth url https://auth.roses.gdvoisins.com:443/
			allow roles authp/admin authp/user
			crypto key verify {env.JWT_SHARED_KEY}
		}
	}
    '';
    # extraConfig = ''

    # '';
    virtualHosts = {
      "auth.roses.gdvoisins.com" = {
          # tls /var/lib/acme/auth.roses.gdvoisins.com/fullchain.pem /var/lib/acme/auth.roses.gdvoisins.com/key.pem
        extraConfig = ''
          authenticate with myportal
          respond "auth.roses.gdvoisins.com is running"
        '';
      };
      "saml.roses.gdvoisins.com" = {
        extraConfig = ''
          authenticate with samlportal
          respond "saml.roses.gdvoisins.com is running"
        '';
      };
      "fontenay.gdvoisins.com" = {
          # tls /var/lib/acme/fontenay.gdvoisins.com/fullchain.pem /var/lib/acme/fontenay.gdvoisins.com/key.pem
        extraConfig = ''
          authorize with samlidentified
          # reverse_proxy https://fontenay.gdvoisins.com:443
          respond "fontenay.gdvoisins.com is running"
        '';
      };
      "roses.gdvoisins.com" = {
          # tls /var/lib/acme/roses.gdvoisins.com/fullchain.pem /var/lib/acme/roses.gdvoisins.com/key.pem
        extraConfig = ''
          respond "Hello There Bonjour etc."
        '';
      };
      "cp.roses.gdvoisins.com" = {
          # tls /var/lib/acme/cp.roses.gdvoisins.com/fullchain.pem /var/lib/acme/cp.roses.gdvoisins.com/key.pem
        # [mannchri@rosest330:~]$ ls /var/lib/copyparty/ssl-public/
        # ca.key  ca.pem  cfssl.json  srv.key  srv.pem
        extraConfig = ''
          authorize with identified
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
          # tls /var/lib/acme/public.cp.roses.gdvoisins.com/fullchain.pem /var/lib/acme/public.cp.roses.gdvoisins.com/key.pem
      "public.cp.roses.gdvoisins.com" = {
        extraConfig = ''
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
          # tls /var/lib/acme/fs.roses.gdvoisins.com/fullchain.pem /var/lib/acme/fs.roses.gdvoisins.com/key.pem
      "fs.roses.gdvoisins.com" = {
        extraConfig = ''
          respond "fs.roses.gdvoisins.com"
        '';
      };
          # tls /var/lib/acme/cw.roses.gdvoisins.com/fullchain.pem /var/lib/acme/cw.roses.gdvoisins.com/key.pem
      "cw.roses.gdvoisins.com" = {
        extraConfig = ''
          respond "cw.roses.gdvoisins.com"
        '';
        };
          # tls /var/lib/acme/op.roses.gdvoisins.com/fullchain.pem /var/lib/acme/op.roses.gdvoisins.com/key.pem
      "op.roses.gdvoisins.com" = {
        extraConfig = ''
          respond "op.roses.gdvoisins.com"
        '';
        };
    };
  };
}