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
      #         idp_metadata_location https://keycloak.gdvoisins.com/realms/master/protocol/saml/descriptor

    # saml identity provider samlkey {
    #     driver generic
    #     realm samlkey
    #     application_name "Key LesGrandsVoisins com"
    #     acs_url https://saml.roses.gdvoisins.com
    #     acs_url https://cp.roses.gdvoisins.com
    #     application_id "samlcopyparty"
    #     entity_id "samlcopyparty"
    #     idp_sign_cert_location "/var/lib/caddy/samlcopyparty.pem"
    #     idp_login_url https://keycloak.gdvoisins.com/realms/master/protocol/saml
    #     idp_metadata_location "/var/lib/caddy/samlkeylesgrandsvoisinscom.xml"
    #   }

		# authentication portal samlportal {
		# 	crypto default token lifetime 3600
		# 	crypto key sign-verify {env.JWT_SHARED_KEY}
		# 	enable identity provider samlkey
		# 	cookie domain gdvoisins.com
		# 	ui {
		# 		links {
		# 			"Copyparty" https://not.roses.gdvoisins.com:443/ icon "las la-star"
		# 			"Moi" "/whoami" icon "las la-user"
		# 		}    		
		# 	}
    #   transform user {
    #     match origin samlportal
		# 		action add role authp/user
		# 	}

		# }
		# authorization policy samlidentified {
		# 	set auth url https://saml.roses.gdvoisins.com:443/
		# 	allow roles guest authp/admin authp/user
		# 	crypto key verify {env.JWT_SHARED_KEY}
		# }

      # "saml.roses.gdvoisins.com" = {
      #   extraConfig = ''
      #     authenticate with samlportal
      #     respond "saml.roses.gdvoisins.com is running"
      #   '';
      # };

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
			metadata_url https://keycloak.gdvoisins.com/realms/master/.well-known/openid-configuration
		}

		authentication portal keygdvoisinscom {
			crypto default token lifetime 3600
			crypto key sign-verify {env.JWT_SHARED_KEY}
			enable identity provider keycloak
			cookie domain gdvoisins.com
			ui {
				links {
					"Copyparty" https://cp.roses.gdvoisins.com:443/ icon "las la-star"
					"Moi" "/whoami" icon "las la-user"
				}
			}

      transform user {
        match origin keycloak
				action add role authp/user
			}
		}

		authorization policy identifiedpolicy {
			set auth url https://auth.roses.gdvoisins.com
			allow roles guest authp/admin authp/user
			crypto key verify {env.JWT_SHARED_KEY}
		}

		authorization policy userpolicy {
			set auth url https://auth.roses.gdvoisins.com
			allow roles authp/admin authp/user
			crypto key verify {env.JWT_SHARED_KEY}
		}
	}
    '';

    virtualHosts = {
      "auth.roses.gdvoisins.com" = {
        extraConfig = ''
          authenticate with keygdvoisinscom
          respond "auth.roses.gdvoisins.com is running"
        '';
      };

      "fontenay.gdvoisins.com" = {
          # tls /var/lib/acme/fontenay.gdvoisins.com/fullchain.pem /var/lib/acme/fontenay.gdvoisins.com/key.pem
        extraConfig = ''
          respond "fontenay.gdvoisins.com is running"
        '';
      };
      "roses.gdvoisins.com" = {
        extraConfig = ''
          respond "roses.gdvoisins.com fonctionne."
        '';
      };
      "cp.roses.gdvoisins.com" = {
        extraConfig = ''
          authorize with identifiedpolicy
          reverse_proxy https://[::1]:3923 {
            request_header  X-REMOTE-USER {rp.header.X-Token-Subject}
            request_header  X-REMOTE-EMAIL {rp.header.X-User-Email}
            request_header  X-REMOTE-USERNAME {rp.header.X-User-Name}
            request_header  X-REMOTE-GROUPS {rp.header.X-User-Roles}
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
          # respond "op.roses.gdvoisins.com fonctionne bien."
          # tls /var/lib/acme/op.roses.gdvoisins.com/fullchain.pem /var/lib/acme/op.roses.gdvoisins.com/key.pem
      "op.roses.gdvoisins.com" = {
        extraConfig = ''
          reverse_proxy 0.0.0.0:1234
        '';
        };
    };
  };
}