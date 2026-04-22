{
  config,
  pkgs,
  lib,
  ...
}: let
  nginxLocationWagtailExtraConfig = ''
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_redirect off;
    proxy_http_version 1.1;
    proxy_set_header X-Forwarded-Proto $scheme;
    # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    # proxy_set_header Host $host;
    # proxy_set_header Upgrade $http_upgrade;
    # proxy_set_header Connection $connection_upgrade_keepalive;
  '';
  nginxLesGrandsVoisinsExtraConfig = ''
    # proxy_protocol off;
    if ($host = 'meet.resdigita.com') {
      return 302 https://jitsi.grandzine.org/resdigita;
    }
    if ($host = 'www.gdvoisins.org') {
      return 302 https://www.gdvoisins.com$request_uri;
    }
    if ($host = 'www.lesgrandsvoisins.fr') {
      return 302 https://www.lesgrandsvoisins.com$request_uri;
    }
    # Static assets: cache for a year (with versioned filenames)
    location ~* \.(?:css|js|woff2?|ttf|eot|ico|gif|jpg|jpeg|png|webp|svg)$ {
        expires 1w;
        add_header Cache-Control "public, max-age=31536000, immutable";
    }

    # HTML: cache very briefly (optional)
    location ~* \.(?:html)$ {
        expires 5m;
        add_header Cache-Control "public, max-age=300, must-revalidate";
    }

    # # API responses: no caching
    # location /api/ {
    #     add_header Cache-Control "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0";
    #     proxy_pass http://localhost:8080;
    # }

    # Optionally disable ETag if you rely on versioned files
    etag off;
  '';
  nginxLesGrandsVoisinsLocations = {
    "/" = {
      # return =  "302 https://blog.lesgrandsvoisins.com";
      proxyPass = "http://localhost:8904/";
      # proxyPass = "http://localhost:8894/";
      # extraConfig = nginxLocationWagtailExtraConfig + ''
      extraConfig = ''
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-Proto $scheme;

        # add_header Cache-Control "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0";

        expires 5m;
        add_header Cache-Control "public, max-age=300, must-revalidate";

        # proxy_set_header Host $host;
        # proxy_set_header Upgrade $http_upgrade;
        # proxy_set_header Connection $connection_upgrade_keepalive;
        # return 302 $scheme://www.grandsvoisins.com$request_uri;
        if ($host = 'www.gvois.org') {
          return 301 $scheme://www.gvois.com$request_uri;
        }
        # if ($host = 'grandsvoisins.org') {
        #   return 301 $scheme://www.grandsvoisins.org$request_uri;
        # }
        # if ($host = 'lgv.info') {
        #   return 301 $scheme://www.lgv.info$request_uri;
        # }
        # if ($host = 'lesgrandsvoisins.fr') {
        #   return 301 $scheme://www.lesgrandsvoisins.fr$request_uri;
        # }
        # if ($host = 'lesgv.com') {
        #   return 301 $scheme://www.lesgv.com$request_uri;
        # }
        # if ($host = 'lesgv.org') {
        #   return 301 $scheme://www.lesgv.org$request_uri;
        # }
        # if ($host = 'parisle.com') {
        #   return 301 $scheme://www.parisle.com$request_uri;
        # }
        # if ($host = 'yanlomsprod.parisle.org') {
        #   return 301 $scheme://yanlomsprod.parisle.com$request_uri;
        # }
        # if ($host = 'coopgv.com') {
        #   return 301 $scheme://www.coopgv.com$request_uri;
        # }
        # if ($host = 'parisle.org') {
        #   return 301 $scheme://www.parisle.org$request_uri;
        # }
        rewrite ^/cms-admin/login/?$ /accounts/oidc/key-gv-je/login/?process=cms-admin/login/ redirect;
      '';
    };
    "/fr/accounts/profile/".extraConfig = ''
      return 302 /;
    '';
    "/en/accounts/profile/".extraConfig = ''
      return 302 /;
    '';
    "/favicon.ico" = {proxyPass = null;};
    "/static" = {proxyPass = null;};
    "/media" = {proxyPass = null;};
    "/medias" = {proxyPass = null;};
    "/.well-known" = {proxyPass = null;};
    "/index.php" = {
      extraConfig = ''
        return 404;
      '';
    };
  };
in {
  services.nginx.virtualHosts = {
    "les.gv.coop" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/interetpublic";
    };
    # "www.hopgv.com" = {
    #   enableACME = true;
    #   forceSSL = true;
    #   root = "/var/www/interetpublic";
    #   serverAliases = ["hopgv.com"];
    #   extraConfig = ''
    #     if ($host != "www.hopgv.com") {
    #       return 301 $scheme://www.hopgv.com$request_uri;
    #     }
    #   '';
    # };
    # "www.interet-public.org" = {
    #   extraConfig = "# proxy_protocol off;";
    #   enableACME = true;
    #   forceSSL = true;
    #   root = "/var/www/interetpublic";
    #   serverAliases = ["www.interetpublic.org"];
    #   locations."/".extraConfig = ''
    #     if ($host != "www.interet-public.org") {
    #       return 301 $scheme://www.interet-public.org$request_uri;
    #     }
    #   '';
    # };
    "gv.village.ngo" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/www-fastoche/";
      locations."/" = {
        proxyPass = "http://localhost:8893/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/medias" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    # "old.lesgrandsvoisins.com" = {
    #   enableACME = true;
    #   forceSSL = true;
    #   root = "/var/www/lesgrandsvoisins/";
    #   # root = "/var/www/coopgv/";
    #   locations."/" = {
    #     # return =  "302 https://blog.lesgrandsvoisins.com";
    #     proxyPass = "http://localhost:8894/";
    #     extraConfig = nginxLocationWagtailExtraConfig + ''
    #       # rewrite ^/cms-admin/login/?$ https://www.lesgrandsvoisins.com/accounts/oidc/key-gv-je/login/?process=cms-admin/login/ redirect;
    #     '';
    #   };
    #   locations."/favicon.ico" = { proxyPass = null; };
    #   locations."/static" = { proxyPass = null; };
    #   locations."/medias" = { proxyPass = null; };
    #   locations."/.well-known" = { proxyPass = null; };
    # };
    "lgv.info" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/html/";
      serverAliases = [
        # "hopgv.org"
        # "lesgv.com"
        "coopgv.com"
        "coopgv.org"
        "grandsvoisins.com"
        "grandsvoisins.org"
        # "gv.coop"
        "libregood.com"
        # "gvcoop.com"
        # "gvcoop.org"
        # "interet-public.org"
        # "interetpublic.org"
        # "lesgrandsvoisins.com"
        # "lesgrandsvoisins.fr"
        "lesgv.org"
        # "ngovillage.org"
        # "ngvillage.org"
        # "ongovillage.com"
        # "ongovillage.org"
        # "ongvillage.com"
        # "ongvillage.org"
        # "parisle.com"
        # "gdvox.com"
        # "parisle.org"
        # "parislenuage.com"
        # "resdigita.com"
        "resdigita.org"
        # "shitmuststop.com"
        # "village.ngo"
        # "village.ong"
        # "villagengo.com"
        # "villagengo.org"
        # "villageparis.org"
        # "syprete.com"
        # "cfran.org"
        # "l-g-v.org"
        "l-g-v.com"
        "maelanc.com"
        # "gdvoisins.com"
        # "l14s.com"
        # "gdv1.com"
        # "gdv1.org"
        "yanlomsprod.org"
        "gdvoisins.org"
        "gvois.org"
        "parisgv.org"
        # "gvois.com"
        "parisgv.com"
        "configmagic.com"
        "grandv.org"
        "parisle.com"
      ];
      extraConfig = ''
        return 301 $scheme://www.$host$request_uri;
      '';
    };
    "lesgrandsvoisins.com" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/html/";
      serverAliases = [
        "lesgrandsvoisins.fr"
      ];
      extraConfig = ''
        return 301 $scheme://www.$host$request_uri;
      '';
    };
    "lesgv.com" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/html/";
      serverAliases = [
        "gdvoisins.com"
        "resdigita.com"
        # "resdigita.org"
        "shitmuststop.com"
      ];
      extraConfig = ''
        return 301 $scheme://www.$host$request_uri;
      '';
    };
    "www.gv.coop" = {
      serverAliases = [
        # "www.lesgv.org"
        # "www.lesgv.com"
        # "www.lgv.info"
        "www.libregood.com"
        # "www.gdvoisins.com"
        # "www.gdvoisins.org"
        # "www.hopgv.org"
      ];
      enableACME = true;
      forceSSL = true;
      root = "/var/www/wagtailgvcoop/";
      locations."/" = {
        proxyPass = "http://localhost:8905/";
        extraConfig =
          nginxLocationWagtailExtraConfig
          + ''
            return 302 $scheme://www.lesgrandsvoisins.com$request_uri;
            # return 302 $scheme://www.grandsvoisins.com$request_uri;
              if ($host = 'gv.coop') {
                return 301 $scheme://www.gv.coop$request_uri;
              }
              # rewrite ^/admin/login/?$ https://www.gv.coop/accounts/oidc/key-gv-je/login/?process=admin/login/ redirect;
          '';
      };
      locations."/fr/accounts/profile/".extraConfig = ''
        return 302 /;
      '';
      locations."/en/accounts/profile/".extraConfig = ''
        return 302 /;
      '';
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/medias" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "www.grandsvoisins.org" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = ["www.grandsvoisins.com"];
      enableACME = true;
      forceSSL = true;
      root = "/var/www/wagtail-lesgrandsvoisinscom/";
      locations."/" = {
        proxyPass = "http://localhost:8906/";
        extraConfig =
          nginxLocationWagtailExtraConfig
          + ''
            return 301 $scheme://www.lesgrandsvoisins.com$request_uri;
            # if ($host != 'www.grandsvoisins.com') {
            #   return 301 $scheme://www.grandsvoisins.com$request_uri;
            # }
            # rewrite ^/cms-admin/login/?$ /accounts/oidc/key-gv-je/login/?process=cms-admin/login/ redirect;
          '';
      };
      locations."/fr/accounts/profile/".extraConfig = ''
        return 302 /;
      '';
      locations."/en/accounts/profile/".extraConfig = ''
        return 302 /;
      '';
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "www.gdvoisins.org" = {
      serverAliases = ["old.gdvoisins.org"];
      enableACME = true;
      forceSSL = true;
      # root = "/var/www/lesgrandsvoisins/";
      root = "/var/www/coopgv/";
      extraConfig = nginxLesGrandsVoisinsExtraConfig;
      locations = nginxLesGrandsVoisinsLocations;
    };

    "www.lesgrandsvoisins.fr" = {
      serverAliases = [
        # "meet.lesgrandsvoisins.com"
        # "www.lesgrandsvoisins.fr"
        # "www.gdvoisins.com"
        "en.gdvoisins.com"
        "fr.archive.gdvoisins.com"
        "en.archive.gdvoisins.com"
        "archive.gdvoisins.com"
        "fr.gdvoisins.com"
      ];
      enableACME = true;
      forceSSL = true;
      # root = "/var/www/lesgrandsvoisins/";
      root = "/var/www/coopgv/";
      extraConfig = nginxLesGrandsVoisinsExtraConfig;
      locations = nginxLesGrandsVoisinsLocations;
    };
    "www.lesgrandsvoisins.com" = {
      serverAliases = [
        "meet.lesgrandsvoisins.com"
        # "www.lesgrandsvoisins.fr"
        "www.gdvoisins.com"
        # "en.gdvoisins.com"
        # "fr.archive.gdvoisins.com"
        # "en.archive.gdvoisins.com"
        # "archive.gdvoisins.com"
        # "fr.gdvoisins.com"
        # "www.gdvoisins.org"
        # "old.gdvoisins.org"
      ];
      enableACME = true;
      forceSSL = true;
      # root = "/var/www/lesgrandsvoisins/";
      root = "/var/www/coopgv/";
      extraConfig = nginxLesGrandsVoisinsExtraConfig;
      locations = nginxLesGrandsVoisinsLocations;
      # locations."/index.php" = {
      #   extraConfig = ''
      #     return 404;
      #   '';
      # };
      # extraConfig = ''
      #   # proxy_protocol off;
      #   if ($host = 'meet.resdigita.com') {
      #     return 302 https://jitsi.grandzine.org/resdigita;
      #   }
      #   if ($host = 'www.gdvoisins.org') {
      #     return 302 https://www.gdvoisins.com$request_uri;
      #   }
      #   if ($host = 'www.lesgrandsvoisins.fr') {
      #     return 302 https://www.lesgrandsvoisins.com$request_uri;
      #   }
      #   # Static assets: cache for a year (with versioned filenames)
      #   location ~* \.(?:css|js|woff2?|ttf|eot|ico|gif|jpg|jpeg|png|webp|svg)$ {
      #       expires 1w;
      #       add_header Cache-Control "public, max-age=31536000, immutable";
      #   }

      #   # HTML: cache very briefly (optional)
      #   location ~* \.(?:html)$ {
      #       expires 5m;
      #       add_header Cache-Control "public, max-age=300, must-revalidate";
      #   }

      #   # # API responses: no caching
      #   # location /api/ {
      #   #     add_header Cache-Control "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0";
      #   #     proxy_pass http://localhost:8080;
      #   # }

      #   # Optionally disable ETag if you rely on versioned files
      #   etag off;
      # '';
      # locations."/" = {
      #   # return =  "302 https://blog.lesgrandsvoisins.com";
      #   proxyPass = "http://localhost:8904/";
      #   # proxyPass = "http://localhost:8894/";
      #   # extraConfig = nginxLocationWagtailExtraConfig + ''
      #   extraConfig = ''
      #     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      #     proxy_redirect off;
      #     proxy_http_version 1.1;
      #     proxy_set_header X-Forwarded-Proto $scheme;

      #     # add_header Cache-Control "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0";

      #     expires 5m;
      #     add_header Cache-Control "public, max-age=300, must-revalidate";

      #     # proxy_set_header Host $host;
      #     # proxy_set_header Upgrade $http_upgrade;
      #     # proxy_set_header Connection $connection_upgrade_keepalive;
      #     # return 302 $scheme://www.grandsvoisins.com$request_uri;
      #     if ($host = 'www.gvois.org') {
      #       return 301 $scheme://www.gvois.com$request_uri;
      #     }
      #     # if ($host = 'grandsvoisins.org') {
      #     #   return 301 $scheme://www.grandsvoisins.org$request_uri;
      #     # }
      #     # if ($host = 'lgv.info') {
      #     #   return 301 $scheme://www.lgv.info$request_uri;
      #     # }
      #     # if ($host = 'lesgrandsvoisins.fr') {
      #     #   return 301 $scheme://www.lesgrandsvoisins.fr$request_uri;
      #     # }
      #     # if ($host = 'lesgv.com') {
      #     #   return 301 $scheme://www.lesgv.com$request_uri;
      #     # }
      #     # if ($host = 'lesgv.org') {
      #     #   return 301 $scheme://www.lesgv.org$request_uri;
      #     # }
      #     # if ($host = 'parisle.com') {
      #     #   return 301 $scheme://www.parisle.com$request_uri;
      #     # }
      #     # if ($host = 'yanlomsprod.parisle.org') {
      #     #   return 301 $scheme://yanlomsprod.parisle.com$request_uri;
      #     # }
      #     # if ($host = 'coopgv.com') {
      #     #   return 301 $scheme://www.coopgv.com$request_uri;
      #     # }
      #     # if ($host = 'parisle.org') {
      #     #   return 301 $scheme://www.parisle.org$request_uri;
      #     # }
      #     rewrite ^/cms-admin/login/?$ /accounts/oidc/key-gv-je/login/?process=cms-admin/login/ redirect;
      #   '';
      # };
      # locations."/fr/accounts/profile/".extraConfig = ''
      #   return 302 /;
      # '';
      # locations."/en/accounts/profile/".extraConfig = ''
      #   return 302 /;
      # '';
      # locations."/favicon.ico" = {proxyPass = null;};
      # locations."/static" = {proxyPass = null;};
      # locations."/media" = {proxyPass = null;};
      # locations."/medias" = {proxyPass = null;};
      # locations."/.well-known" = {proxyPass = null;};
    };
    "meet.resdigita.com" = {
      serverAliases = [
        "admin.parisle.com"
        "ai.parisle.com"
        "alt.lesgrandsvoisins.com"
        "en.lesgrandsvoisins.com"
        "fr.lesgrandsvoisins.com"
        "gvcoop.lesgrandsvoisins.com"
        "test.lesgrandsvoisins.com"
        "www.coopgv.com"
        "yanlomsprod.parisle.com"
        "yanlomsprod.parisle.org"
        # "excellenxport.hopgv.com"
        # "old.lesgrandsvoisins.com"
        "meet.mann.faith"
        "www.yanlomsprod.org"
        # "www.lgv.info"
      ];
      enableACME = true;
      forceSSL = true;
      # root = "/var/www/lesgrandsvoisins/";
      root = "/var/www/coopgv/";
      extraConfig = nginxLesGrandsVoisinsExtraConfig;
      locations = nginxLesGrandsVoisinsLocations;
      # locations."/index.php" = {
      #   extraConfig = ''
      #     return 404;
      #   '';
      # };
      # extraConfig = ''
      #   # proxy_protocol off;
      #   if ($host = 'meet.resdigita.com') {
      #     return 302 https://jitsi.grandzine.org/resdigita;
      #   }
      #   if ($host = 'www.gdvoisins.org') {
      #     return 302 https://www.gdvoisins.com$request_uri;
      #   }
      #   if ($host = 'www.lesgrandsvoisins.fr') {
      #     return 302 https://www.lesgrandsvoisins.com$request_uri;
      #   }
      #   # Static assets: cache for a year (with versioned filenames)
      #   location ~* \.(?:css|js|woff2?|ttf|eot|ico|gif|jpg|jpeg|png|webp|svg)$ {
      #       expires 1w;
      #       add_header Cache-Control "public, max-age=31536000, immutable";
      #   }

      #   # HTML: cache very briefly (optional)
      #   location ~* \.(?:html)$ {
      #       expires 5m;
      #       add_header Cache-Control "public, max-age=300, must-revalidate";
      #   }

      #   # # API responses: no caching
      #   # location /api/ {
      #   #     add_header Cache-Control "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0";
      #   #     proxy_pass http://localhost:8080;
      #   # }

      #   # Optionally disable ETag if you rely on versioned files
      #   etag off;
      # '';
      # # locations."/fr/search" = {
      # #   extraConfig =  ''
      # #       return 302 $scheme://$host$request_uri;
      # #   '';
      # # };
      # locations."/" = {
      #   # return =  "302 https://blog.lesgrandsvoisins.com";
      #   proxyPass = "http://localhost:8904/";
      #   # proxyPass = "http://localhost:8894/";
      #   # extraConfig = nginxLocationWagtailExtraConfig + ''
      #   extraConfig = ''
      #     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      #     proxy_redirect off;
      #     proxy_http_version 1.1;
      #     proxy_set_header X-Forwarded-Proto $scheme;

      #     # add_header Cache-Control "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0";

      #     expires 5m;
      #     add_header Cache-Control "public, max-age=300, must-revalidate";

      #     # proxy_set_header Host $host;
      #     # proxy_set_header Upgrade $http_upgrade;
      #     # proxy_set_header Connection $connection_upgrade_keepalive;
      #     # return 302 $scheme://www.grandsvoisins.com$request_uri;
      #     if ($host = 'www.gvois.org') {
      #       return 301 $scheme://www.gvois.com$request_uri;
      #     }
      #     # if ($host = 'grandsvoisins.org') {
      #     #   return 301 $scheme://www.grandsvoisins.org$request_uri;
      #     # }
      #     # if ($host = 'lgv.info') {
      #     #   return 301 $scheme://www.lgv.info$request_uri;
      #     # }
      #     # if ($host = 'lesgrandsvoisins.fr') {
      #     #   return 301 $scheme://www.lesgrandsvoisins.fr$request_uri;
      #     # }
      #     # if ($host = 'lesgv.com') {
      #     #   return 301 $scheme://www.lesgv.com$request_uri;
      #     # }
      #     # if ($host = 'lesgv.org') {
      #     #   return 301 $scheme://www.lesgv.org$request_uri;
      #     # }
      #     # if ($host = 'parisle.com') {
      #     #   return 301 $scheme://www.parisle.com$request_uri;
      #     # }
      #     # if ($host = 'yanlomsprod.parisle.org') {
      #     #   return 301 $scheme://yanlomsprod.parisle.com$request_uri;
      #     # }
      #     # if ($host = 'coopgv.com') {
      #     #   return 301 $scheme://www.coopgv.com$request_uri;
      #     # }
      #     # if ($host = 'parisle.org') {
      #     #   return 301 $scheme://www.parisle.org$request_uri;
      #     # }
      #     rewrite ^/cms-admin/login/?$ /accounts/oidc/key-gv-je/login/?process=cms-admin/login/ redirect;
      #   '';
      # };
      # locations."/fr/accounts/profile/".extraConfig = ''
      #   return 302 /;
      # '';
      # locations."/en/accounts/profile/".extraConfig = ''
      #   return 302 /;
      # '';
      # locations."/favicon.ico" = {proxyPass = null;};
      # locations."/static" = {proxyPass = null;};
      # locations."/media" = {proxyPass = null;};
      # locations."/medias" = {proxyPass = null;};
      # locations."/.well-known" = {proxyPass = null;};
    };
    # "www.gvois.com" = {
    #   extraConfig = "# proxy_protocol off;";
    #   serverAliases = [
    #     "www.gvois.org"
    #     "bigbluebutton.gvois.com"
    #     "bind.gvois.com"
    #     "cherryldap.gvois.com"
    #     "crabfit.gvois.com"
    #     "discourse.gvois.com"
    #     "fossil.gvois.com"
    #     "ghost.gvois.com"
    #     "gitea.gvois.com"
    #     "hedgedoc.gvois.com"
    #     "homepagedashboard.gvois.com"
    #     "keycloak.gvois.com"
    #     "linkding.gvois.com"
    #     "listmonk.gvois.com"
    #     "nixos.gvois.com"
    #     "odoo.gvois.com"
    #     "openldap.gvois.com"
    #     "photoprism.gvois.com"
    #     "quartz.gvois.com"
    #     "radicale.gvois.com"
    #     "roundcube.gvois.com"
    #     "seafile.gvois.com"
    #     "sftpgo.gvois.com"
    #     "silverbullet.gvois.com"
    #     "syncthing.gvois.com"
    #     "vaultwarden.gvois.com"
    #     "vikunja.gvois.com"
    #     "wagtail.gvois.com"
    #     "webdav.gvois.com"
    #     "wordpress.gvois.com"
    #     "admin.gvois.com"
    #     "ai.gvois.com"
    #     "annuaire.gvois.com"
    #     "backup.gvois.com"
    #     "blog.gvois.com"
    #     "cal.gvois.com"
    #     "cloud.gvois.com"
    #     "code.gvois.com"
    #     "config.gvois.com"
    #     "contacts.gvois.com"
    #     "discussion.gvois.com"
    #     "docs.gvois.com"
    #     "drive.gvois.com"
    #     "finance.gvois.com"
    #     "forms.gvois.com"
    #     "forum.gvois.com"
    #     "id.gvois.com"
    #     "list.gvois.com"
    #     "mail.gvois.com"
    #     "meet.gvois.com"
    #     "net.gvois.com"
    #     "pay.gvois.com"
    #     "photos.gvois.com"
    #     "secret.gvois.com"
    #     "sites.gvois.com"
    #     "sync.gvois.com"
    #     "task.gvois.com"
    #     "url.gvois.com"
    #     "videos.gvois.com"
    #     "wiki.gvois.com"
    #   ];
    #   enableACME = true;
    #   forceSSL = true;
    #   # root = "/var/www/lesgrandsvoisins/";
    #   root = "/var/www/coopgv/";
    #   locations."/" = {
    #     # return =  "302 https://blog.lesgrandsvoisins.com";
    #     proxyPass = "http://localhost:8904/";
    #     extraConfig =
    #       nginxLocationWagtailExtraConfig
    #       + ''
    #         # return 302 $scheme://www.grandsvoisins.com$request_uri;
    #         if ($host = 'www.gvois.org') {
    #           return 301 $scheme://www.gvois.com$request_uri;
    #         }
    #         rewrite ^/cms-admin/login/?$ /accounts/oidc/key-gv-je/login/?process=cms-admin/login/ redirect;
    #       '';
    #   };
    #   locations."/fr/accounts/profile/".extraConfig = ''
    #     return 302 /;
    #   '';
    #   locations."/en/accounts/profile/".extraConfig = ''
    #     return 302 /;
    #   '';
    #   locations."/favicon.ico" = {proxyPass = null;};
    #   locations."/static" = {proxyPass = null;};
    #   locations."/media" = {proxyPass = null;};
    #   locations."/medias" = {proxyPass = null;};
    #   locations."/.well-known" = {proxyPass = null;};
    # };
    "www.lesgv.org" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = [
        # "www.gvois.org"
        "bigbluebutton.lesgv.org"
        "bind.lesgv.org"
        "cherryldap.lesgv.org"
        "crabfit.lesgv.org"
        "discourse.lesgv.org"
        "fossil.lesgv.org"
        "ghost.lesgv.org"
        "gitea.lesgv.org"
        "hedgedoc.lesgv.org"
        "homepagedashboard.lesgv.org"
        "keycloak.lesgv.org"
        "linkding.lesgv.org"
        "listmonk.lesgv.org"
        "nixos.lesgv.org"
        "odoo.lesgv.org"
        "openldap.lesgv.org"
        "photoprism.lesgv.org"
        "quartz.lesgv.org"
        "radicale.lesgv.org"
        "roundcube.lesgv.org"
        "seafile.lesgv.org"
        "sftpgo.lesgv.org"
        "silverbullet.lesgv.org"
        "syncthing.lesgv.org"
        "vaultwarden.lesgv.org"
        "vikunja.lesgv.org"
        "wagtail.lesgv.org"
        "webdav.lesgv.org"
        "wordpress.lesgv.org"
        "admin.lesgv.org"
        "ai.lesgv.org"
        "annuaire.lesgv.org"
        "backup.lesgv.org"
        "blog.lesgv.org"
        "cal.lesgv.org"
        "cloud.lesgv.org"
        "code.lesgv.org"
        "config.lesgv.org"
        "contacts.lesgv.org"
        "discussion.lesgv.org"
        "docs.lesgv.org"
        "drive.lesgv.org"
        "finance.lesgv.org"
        "forms.lesgv.org"
        "forum.lesgv.org"
        "id.lesgv.org"
        "list.lesgv.org"
        "mail.lesgv.org"
        "meet.lesgv.org"
        "net.lesgv.org"
        "pay.lesgv.org"
        "photos.lesgv.org"
        "secret.lesgv.org"
        "sites.lesgv.org"
        "sync.lesgv.org"
        "task.lesgv.org"
        "url.lesgv.org"
        "videos.lesgv.org"
        "wiki.lesgv.org"
      ];
      enableACME = true;
      forceSSL = true;
      # root = "/var/www/lesgrandsvoisins/";
      root = "/var/www/coopgv/";
      locations."/" = {
        # return =  "302 https://blog.lesgrandsvoisins.com";
        proxyPass = "http://localhost:8904/";
        extraConfig =
          nginxLocationWagtailExtraConfig
          + ''
            # return 302 $scheme://www.grandsvoisins.com$request_uri;
            if ($host = 'www.gvois.org') {
              return 301 $scheme://www.lesgv.org$request_uri;
            }
            rewrite ^/cms-admin/login/?$ /accounts/oidc/key-gv-je/login/?process=cms-admin/login/ redirect;
          '';
      };
      locations."/fr/accounts/profile/".extraConfig = ''
        return 302 /;
      '';
      locations."/en/accounts/profile/".extraConfig = ''
        return 302 /;
      '';
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/medias" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    # "www.parisgv.com" = {
    #   extraConfig = "# proxy_protocol off;";
    #   serverAliases = [
    #     "www.parisgv.org"
    #     "bigbluebutton.parisgv.com"
    #     "bind.parisgv.com"
    #     "cherryldap.parisgv.com"
    #     "crabfit.parisgv.com"
    #     "discourse.parisgv.com"
    #     "fossil.parisgv.com"
    #     "ghost.parisgv.com"
    #     "gitea.parisgv.com"
    #     "hedgedoc.parisgv.com"
    #     "homepagedashboard.parisgv.com"
    #     "keycloak.parisgv.com"
    #     "linkding.parisgv.com"
    #     "listmonk.parisgv.com"
    #     "nixos.parisgv.com"
    #     "odoo.parisgv.com"
    #     "openldap.parisgv.com"
    #     "photoprism.parisgv.com"
    #     "quartz.parisgv.com"
    #     "radicale.parisgv.com"
    #     "roundcube.parisgv.com"
    #     "seafile.parisgv.com"
    #     "sftpgo.parisgv.com"
    #     "silverbullet.parisgv.com"
    #     "syncthing.parisgv.com"
    #     "vaultwarden.parisgv.com"
    #     "vikunja.parisgv.com"
    #     "wagtail.parisgv.com"
    #     "webdav.parisgv.com"
    #     "wordpress.parisgv.com"
    #     "admin.parisgv.com"
    #     "ai.parisgv.com"
    #     "annuaire.parisgv.com"
    #     "backup.parisgv.com"
    #     "blog.parisgv.com"
    #     "cal.parisgv.com"
    #     "cloud.parisgv.com"
    #     "code.parisgv.com"
    #     "config.parisgv.com"
    #     "contacts.parisgv.com"
    #     "discussion.parisgv.com"
    #     "docs.parisgv.com"
    #     "drive.parisgv.com"
    #     "finance.parisgv.com"
    #     "forms.parisgv.com"
    #     "forum.parisgv.com"
    #     "id.parisgv.com"
    #     "list.parisgv.com"
    #     "mail.parisgv.com"
    #     "meet.parisgv.com"
    #     "net.parisgv.com"
    #     "pay.parisgv.com"
    #     "photos.parisgv.com"
    #     "secret.parisgv.com"
    #     "sites.parisgv.com"
    #     "sync.parisgv.com"
    #     "task.parisgv.com"
    #     "url.parisgv.com"
    #     "videos.parisgv.com"
    #     "wiki.parisgv.com"
    #   ];
    #   enableACME = true;
    #   forceSSL = true;
    #   # root = "/var/www/lesgrandsvoisins/";
    #   root = "/var/www/coopgv/";
    #   locations."/" = {
    #     # return =  "302 https://blog.lesgrandsvoisins.com";
    #     proxyPass = "http://localhost:8904/";
    #     extraConfig =
    #       nginxLocationWagtailExtraConfig
    #       + ''
    #         # return 302 $scheme://www.grandsvoisins.com$request_uri;
    #         if ($host = 'www.parisgv.org') {
    #           return 301 $scheme://www.parisgv.com$request_uri;
    #         }
    #         rewrite ^/cms-admin/login/?$ /accounts/oidc/key-gv-je/login/?process=cms-admin/login/ redirect;
    #       '';
    #   };
    #   locations."/fr/accounts/profile/".extraConfig = ''
    #     return 302 /;
    #   '';
    #   locations."/en/accounts/profile/".extraConfig = ''
    #     return 302 /;
    #   '';
    #   locations."/favicon.ico" = {proxyPass = null;};
    #   locations."/static" = {proxyPass = null;};
    #   locations."/media" = {proxyPass = null;};
    #   locations."/medias" = {proxyPass = null;};
    #   locations."/.well-known" = {proxyPass = null;};
    # };
    # "www.gdvox.com" = {
    #   extraConfig = "# proxy_protocol off;";
    #   serverAliases = [
    #     "admin.gdvox.com"
    #     "ai.gdvox.com"
    #     "annuaire.gdvox.com"
    #     "backup.gdvox.com"
    #     "blog.gdvox.com"
    #     "cal.gdvox.com"
    #     "cloud.gdvox.com"
    #     "code.gdvox.com"
    #     "config.gdvox.com"
    #     "contacts.gdvox.com"
    #     "discussion.gdvox.com"
    #     "docs.gdvox.com"
    #     "drive.gdvox.com"
    #     "finance.gdvox.com"
    #     "forms.gdvox.com"
    #     "forum.gdvox.com"
    #     "id.gdvox.com"
    #     "list.gdvox.com"
    #     "mail.gdvox.com"
    #     "meet.gdvox.com"
    #     "net.gdvox.com"
    #     "pay.gdvox.com"
    #     "photos.gdvox.com"
    #     "secret.gdvox.com"
    #     "sites.gdvox.com"
    #     "sync.gdvox.com"
    #     "task.gdvox.com"
    #     "url.gdvox.com"
    #     "videos.gdvox.com"
    #     "webdav.gdvox.com"
    #     "wiki.gdvox.com"
    #   ];
    #   enableACME = true;
    #   forceSSL = true;
    #   root = "/var/www/gdvox/";
    #   locations."/" = {
    #     proxyPass = "http://localhost:8907/";
    #     extraConfig =
    #       nginxLocationWagtailExtraConfig
    #       + ''
    #         # return 302 $scheme://www.grandsvoisins.com$request_uri;
    #         # if ($host = 'www.parisgv.org') {
    #         #   return 301 $scheme://www.parisgv.com$request_uri;
    #         # }
    #         rewrite ^/admin$ /accounts/oidc/keycloak-gdvox-com/login/?process=cms-admin/login/ redirect;
    #         rewrite ^/cms-admin/login/?$ /accounts/oidc/keycloak-gdvox-com/login/?process=cms-admin/login/ redirect;
    #       '';
    #   };
    #   locations."/fr/accounts/profile/".extraConfig = ''
    #     return 302 /;
    #   '';
    #   locations."/en/accounts/profile/".extraConfig = ''
    #     return 302 /;
    #   '';
    #   locations."/favicon.ico" = {proxyPass = null;};
    #   locations."/static" = {proxyPass = null;};
    #   locations."/media" = {proxyPass = null;};
    #   locations."/.well-known" = {proxyPass = null;};
    # };

    "www.lgv.info" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/coopgv/";
      locations."/".extraConfig = ''
        return 301 https://info.grandsvoisins.org$request_uri;
      '';
    };
    "www.lesgv.com" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/coopgv/";
      locations."/".extraConfig = ''
        return 302 https://www.lesgrandsvoisins.com$request_uri;
      '';
    };
    "admin.lesgv.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = [
        # "admin.lesgv.com"
        "ai.lesgv.com"
        "annuaire.lesgv.com"
        "backup.lesgv.com"
        "blog.lesgv.com"
        "cal.lesgv.com"
        "cloud.lesgv.com"
        "code.lesgv.com"
        "config.lesgv.com"
        "contacts.lesgv.com"
        "discussion.lesgv.com"
        "docs.lesgv.com"
        "drive.lesgv.com"
        "finance.lesgv.com"
        "forms.lesgv.com"
        "forum.lesgv.com"
        "id.lesgv.com"
        "list.lesgv.com"
        "mail.lesgv.com"
        "meet.lesgv.com"
        "net.lesgv.com"
        "pay.lesgv.com"
        "photos.lesgv.com"
        "secret.lesgv.com"
        "sites.lesgv.com"
        "sync.lesgv.com"
        "task.lesgv.com"
        "url.lesgv.com"
        "videos.lesgv.com"
        "webdav.lesgv.com"
        "wiki.lesgv.com"
        "app.lesgv.com"
        # "www.gv.coop"
        # "www.gvcoop.org"
        # "www.lgv.info"
      ];
      enableACME = true;
      forceSSL = true;
      root = "/var/www/coopgv/";
      locations."/" = {
        proxyPass = "http://localhost:8904/";
        extraConfig =
          nginxLocationWagtailExtraConfig
          + ''
            # return 302 $scheme://www.grandsvoisins.com$request_uri;
            if ($host = 'app.lesgv.com') {
              return 302 $scheme://www.lesgv.com$request_uri;
            }
            rewrite ^/admin$ /accounts/oidc/key-gv-je/login/?process=cms-admin/login/ redirect;
            rewrite ^/cms-admin/login/?$ /accounts/oidc/key-gv-je/login/?process=cms-admin/login/ redirect;
          '';
      };
      locations."/fr/accounts/profile/".extraConfig = ''
        return 302 /;
      '';
      locations."/en/accounts/profile/".extraConfig = ''
        return 302 /;
      '';
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/medias" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "apps.gdvoisins.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = [
        "admin.gdvoisins.com"
        "ai.gdvoisins.com"
        "annuaire.gdvoisins.com"
        "backup.gdvoisins.com"
        "blog.gdvoisins.com"
        "cal.gdvoisins.com"
        "cloud.gdvoisins.com"
        "code.gdvoisins.com"
        "config.gdvoisins.com"
        "contacts.gdvoisins.com"
        "discussion.gdvoisins.com"
        "docs.gdvoisins.com"
        "drive.gdvoisins.com"
        "finance.gdvoisins.com"
        "forms.gdvoisins.com"
        "forum.gdvoisins.com"
        "id.gdvoisins.com"
        "list.gdvoisins.com"
        "mail.gdvoisins.com"
        "meet.gdvoisins.com"
        "net.gdvoisins.com"
        "pay.gdvoisins.com"
        "photos.gdvoisins.com"
        "secret.gdvoisins.com"
        "sites.gdvoisins.com"
        "sync.gdvoisins.com"
        "task.gdvoisins.com"
        "url.gdvoisins.com"
        "videos.gdvoisins.com"
        "webdav.gdvoisins.com"
        "wiki.gdvoisins.com"
        "app.gdvoisins.com"
      ];
      enableACME = true;
      forceSSL = true;
      root = "/var/www/coopgv/";
      locations."/" = {
        proxyPass = "http://localhost:8904/";
        extraConfig =
          nginxLocationWagtailExtraConfig
          + ''
            # return 302 $scheme://www.grandsvoisins.com$request_uri;
            if ($host = 'app.lgv.info') {
              return 302 $scheme://www.lgv.info$request_uri;
            }
            rewrite ^/admin$ /accounts/oidc/key-gv-je/login/?process=cms-admin/login/ redirect;
            rewrite ^/cms-admin/login/?$ /accounts/oidc/key-gv-je/login/?process=cms-admin/login/ redirect;
          '';
      };
      locations."/fr/accounts/profile/".extraConfig = ''
        return 302 /;
      '';
      locations."/en/accounts/profile/".extraConfig = ''
        return 302 /;
      '';
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/medias" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "admin.lgv.info" = {
      serverAliases = [
        # "admin.lgv.info"
        "ai.lgv.info"
        "annuaire.lgv.info"
        "backup.lgv.info"
        "blog.lgv.info"
        "cal.lgv.info"
        "cloud.lgv.info"
        "code.lgv.info"
        "config.lgv.info"
        "contacts.lgv.info"
        "discussion.lgv.info"
        "docs.lgv.info"
        "drive.lgv.info"
        "finance.lgv.info"
        "forms.lgv.info"
        "forum.lgv.info"
        "id.lgv.info"
        # "list.lgv.info"
        "mail.lgv.info"
        "meet.lgv.info"
        "net.lgv.info"
        "pay.lgv.info"
        "photos.lgv.info"
        "secret.lgv.info"
        "sites.lgv.info"
        "sync.lgv.info"
        "task.lgv.info"
        "url.lgv.info"
        "videos.lgv.info"
        "webdav.lgv.info"
        # "wiki.lgv.info"
        "app.lgv.info"
        # "www.gv.coop"
      ];
      enableACME = true;
      forceSSL = true;
      root = "/var/www/coopgv/";
      locations."/" = {
        proxyPass = "http://localhost:8904/";
        extraConfig =
          nginxLocationWagtailExtraConfig
          + ''
            # return 302 $scheme://www.grandsvoisins.com$request_uri;
            if ($host = 'app.lgv.info') {
              return 302 $scheme://www.lgv.info$request_uri;
            }
            rewrite ^/admin$ /accounts/oidc/key-gv-je/login/?process=cms-admin/login/ redirect;
            rewrite ^/cms-admin/login/?$ /accounts/oidc/key-gv-je/login/?process=cms-admin/login/ redirect;
          '';
      };
      locations."/fr/accounts/profile/".extraConfig = ''
        return 302 /;
      '';
      locations."/en/accounts/profile/".extraConfig = ''
        return 302 /;
      '';
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/medias" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "www.parisle.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = [
        "www.parisle.org"
        "bigbluebutton.parisle.com"
        "bind.parisle.com"
        "cherryldap.parisle.com"
        "crabfit.parisle.com"
        "discourse.parisle.com"
        "fossil.parisle.com"
        "ghost.parisle.com"
        "gitea.parisle.com"
        "hedgedoc.parisle.com"
        "homepagedashboard.parisle.com"
        "keycloak.parisle.com"
        "linkding.parisle.com"
        "listmonk.parisle.com"
        "nixos.parisle.com"
        "odoo.parisle.com"
        "openldap.parisle.com"
        "photoprism.parisle.com"
        "quartz.parisle.com"
        "radicale.parisle.com"
        "roundcube.parisle.com"
        "seafile.parisle.com"
        "sftpgo.parisle.com"
        "silverbullet.parisle.com"
        "syncthing.parisle.com"
        "vaultwarden.parisle.com"
        "vikunja.parisle.com"
        "wagtail.parisle.com"
        "webdav.parisle.com"
        "wordpress.parisle.com"
        "admin.parisle.com"
        "ai.parisle.com"
        "annuaire.parisle.com"
        "backup.parisle.com"
        "blog.parisle.com"
        "cal.parisle.com"
        "cloud.parisle.com"
        "code.parisle.com"
        "config.parisle.com"
        "contacts.parisle.com"
        "discussion.parisle.com"
        "docs.parisle.com"
        "drive.parisle.com"
        "finance.parisle.com"
        "forms.parisle.com"
        "forum.parisle.com"
        "id.parisle.com"
        "list.parisle.com"
        "mail.parisle.com"
        "meet.parisle.com"
        "net.parisle.com"
        "pay.parisle.com"
        "photos.parisle.com"
        "secret.parisle.com"
        "sites.parisle.com"
        "sync.parisle.com"
        "task.parisle.com"
        "url.parisle.com"
        "videos.parisle.com"
        "wiki.parisle.com"
      ];
      enableACME = true;
      forceSSL = true;
      # root = "/var/www/lesgrandsvoisins/";
      root = "/var/www/coopgv/";
      locations."/" = {
        # return =  "302 https://blog.lesgrandsvoisins.com";
        proxyPass = "http://localhost:8904/";
        extraConfig =
          nginxLocationWagtailExtraConfig
          + ''
            # return 302 $scheme://www.grandsvoisins.com$request_uri;
            if ($host = 'www.parisle.org') {
              return 301 $scheme://www.parisle.com$request_uri;
            }
            rewrite ^/cms-admin/login/?$ /accounts/oidc/key-gv-je/login/?process=cms-admin/login/ redirect;
          '';
      };
      locations."/fr/accounts/profile/".extraConfig = ''
        return 302 /;
      '';
      locations."/en/accounts/profile/".extraConfig = ''
        return 302 /;
      '';
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/medias" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    # "resdigita.village.ngo" = {
    #   serverAliases = [ "resdigita.fastoche.org" ];
    #   enableACME = true;
    #   forceSSL = true;
    #   root = "/var/www/resdigita-fastoche/";
    #   locations."/" = {
    #     proxyPass = "http://localhost:8892/";
    #     extraConfig = nginxLocationWagtailExtraConfig;
    #   };
    #   locations."/favicon.ico" = { proxyPass = null; };
    #   locations."/static" = { proxyPass = null; };
    #   locations."/medias" = { proxyPass = null; };
    #   locations."/.well-known" = { proxyPass = null; };
    # };
    "www.parislenuage.com" = {
      extraConfig = "# proxy_protocol off;";
      locations."/" = {
        extraConfig = ''
          return 302 $scheme://www.parisle.com$request_uri;
        '';
      };
    };
    # "www.francemali.org" = {
    #   enableACME = true;
    #   serverAliases = ["francemali.org"];
    #   forceSSL = true;
    #   root =  "/var/www/francemali/";
    #   extraConfig = ''
    #     if ($host = 'francemali.org') {
    #       return 301 $scheme://www.$host$request_uri;
    #     }
    #     '';
    #   locations."/" = {
    #     proxyPass = "http://localhost:8888/";
    #     extraConfig = nginxLocationWagtailExtraConfig;
    #   };
    #   locations."/favicon.ico" = { proxyPass = null; };
    #   locations."/static" = { proxyPass = null; };
    #   locations."/medias" = { proxyPass = null; };
    #   locations."/.well-known" = { proxyPass = null; };
    # };
    "old.gv.coop" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/village/";
      # extraConfig = ''
      #   if ($host != 'www.village.ong') {
      #     return 301 https://www.village.ong/fr/;
      #   }
      # '';
      locations = {
        "/" = {
          proxyPass = "http://localhost:8896/";
          extraConfig = nginxLocationWagtailExtraConfig;
        };
        # "/en/".return =  "301 http://www.village.ngo$request_uri";
        "/favicon.ico" = {proxyPass = null;};
        "/static" = {proxyPass = null;};
        "/medias" = {proxyPass = null;};
        "/.well-known" = {proxyPass = null;};
      };
    };
    "www.village.ong" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/village/";
      extraConfig = ''
        if ($host != 'www.village.ong') {
          return 301 https://www.village.ong/fr/;
        }
      '';
      locations = {
        "/" = {
          proxyPass = "http://localhost:8896/";
          extraConfig = nginxLocationWagtailExtraConfig;
        };
        "/en/".return = "301 http://www.village.ngo$request_uri";
        "/favicon.ico" = {proxyPass = null;};
        "/static" = {proxyPass = null;};
        "/medias" = {proxyPass = null;};
        "/.well-known" = {proxyPass = null;};
      };
      # if ($host != 'www.village.ong') {
      #   return 301 $scheme://www.village.ong$request_uri;
      # }
      # location ~ /en/(.*)$ {
      #   rewrite ^ https://www.village.ngo/en/$1?$args permanent;
      # }
      # '';
      # locations."/en/" = {
      #   proxyPass = "http://localhost:8896/";
      #   extraConfig = nginxLocationWagtailExtraConfig;
      # };
      # locations."/" = {
      #   proxyPass = "http://localhost:8896/";
      #   extraConfig = nginxLocationWagtailExtraConfig;
      # };
      # locations."/favicon.ico" = { proxyPass = null; };
      # locations."/static" = { proxyPass = null; };
      # locations."/medias" = { proxyPass = null; };
      # locations."/.well-known" = { proxyPass = null; };
    };
    "cantine.resdigita.com" = {
      extraConfig = "# proxy_protocol off;";
      enableACME = true;
      forceSSL = true;
      root = "/var/www/cantine/";
      locations = {
        "/" = {
          proxyPass = "http://localhost:8900/";
          extraConfig = nginxLocationWagtailExtraConfig;
        };
        # "/fr/".return =  "301 http://www.village.ong$request_uri";
        "/favicon.ico" = {proxyPass = null;};
        "/static" = {proxyPass = null;};
        "/medias" = {proxyPass = null;};
        "/.well-known" = {proxyPass = null;};
      };
    };
    "www.village.ngo" = {
      enableACME = true;
      # serverAliases = [
      #   "www.villagengo.org"
      #   "www.villagengo.com"
      #   "www.villageparis.org"
      #   "www.ngovillage.org"
      #   "www.ngvillage.org"
      #   "www.ongovillage.com"
      #   "www.ongovillage.org"
      #   "www.ongvillage.org"
      #   "www.ongvillage.com"
      # ];
      forceSSL = true;
      root = "/var/www/village/";
      # extraConfig = ''
      #   # location ~ /fr/(.*)$ {
      #   #   rewrite ^ https://www.village.ong/fr/$1?$args permanent;
      #   # }
      #   if ($host != 'www.village.ngo') {
      #     return 301 $scheme://www.village.ngo$request_uri;
      #   }
      #   '';
      #         location ~ /fr/(.*)$ {
      #   rewrite ^ https://www.village.ong/fr/$1?$args permanent;
      # }
      locations = {
        "/" = {
          proxyPass = "http://localhost:8896/";
          extraConfig =
            nginxLocationWagtailExtraConfig
            + ''
              # location ~ /fr/(.*)$ {
              #   rewrite ^ https://www.village.ong/fr/$1?$args permanent;
              # }
              if ($host != 'www.village.ngo') {
                return 301 $scheme://www.village.ngo$request_uri;
              }
            '';
        };
        "/fr/".return = "301 http://www.village.ong$request_uri";
        "/favicon.ico" = {proxyPass = null;};
        "/static" = {proxyPass = null;};
        "/medias" = {proxyPass = null;};
        "/.well-known" = {proxyPass = null;};
      };
    };
    # "www.village.ong" = {
    #   enableACME = true;
    #   serverAliases = [
    #     "www.fastoche.org"
    #     "fastoche.org"
    #     "village.ong"
    #     ];
    #   forceSSL = true;
    #   root =  "/var/www/village/";
    #   extraConfig = ''
    #     if ($host != 'www.village.ong') {
    #       return 301 $scheme://www.village.ong$request_uri;
    #     }
    #     '';
    #   locations."/" = {
    #     proxyPass = "http://localhost:8896/";
    #     extraConfig = nginxLocationWagtailExtraConfig;
    #   };
    #   locations."/favicon.ico" = { proxyPass = null; };
    #   locations."/static" = { proxyPass = null; };
    #   locations."/medias" = { proxyPass = null; };
    #   locations."/.well-known" = { proxyPass = null; };
    # };
    # "web.cfran.org" = {
    #   enableACME = true;
    #   serverAliases = [  "www.cfran.org" "web.fastoche.org" ];
    #   forceSSL = true;
    #   root = "/var/www/web-fastoche/";
    #   # extraConfig = ''
    #   #   if ($host != 'web.cfran.org') {
    #   #     return 301 $scheme://web.cfran.org$request_uri;
    #   #   }
    #   #   '';
    #   locations."/" = {
    #     proxyPass = "http://localhost:8889/";
    #     extraConfig = nginxLocationWagtailExtraConfig + ''
    #       if ($host != 'web.cfran.org') {
    #         return 301 $scheme://web.cfran.org$request_uri;
    #       }
    #     '';
    #   };
    #   locations."/favicon.ico" = { proxyPass = null; };
    #   locations."/static" = { proxyPass = null; };
    #   locations."/medias" = { proxyPass = null; };
    #   locations."/.well-known" = { proxyPass = null; };
    # };
    "wagtail.village.ngo" = {
      enableACME = true;
      forceSSL = true;
      serverAliases = ["wagtail.villagengo.org" "wagtail.villagengo.com"];
      root = "/var/www/wagtail-village/";
      locations."/" = {
        proxyPass = "http://localhost:8897/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      # extraConfig = ''
      #   if ($host != 'wagtail.village.ngo') {
      #     return 301 $scheme://wagtail.cfran.org$request_uri;
      #   }
      # '';
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/medias" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "www.resdigita.org" = {
      extraConfig = "# proxy_protocol off;";
      enableACME = true;
      forceSSL = true;
      serverAliases = [
        "en.resdigita.com"
        "fr.resdigita.com"
        "en.resdigita.org"
        "fr.resdigita.org"
      ];
      root = "/var/www/resdigitaorg/";
      locations."/" = {
        proxyPass = "http://localhost:8899/";
        extraConfig =
          nginxLocationWagtailExtraConfig
          + ''
            if ($host = 'resdigita.com') {
              return 301 $scheme://www.resdigita.com$request_uri;
            }
            if ($host = 'resdigita.org') {
              return 301 $scheme://www.resdigita.org$request_uri;
            }
          '';
      };
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/medias" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "wagtail.village.ong" = {
      # serverAliases = [ "wagtail.fastoche.org" "wagtail.cfran.org" ];
      enableACME = true;
      forceSSL = true;
      root = "/var/www/wagtail-village/";
      locations."/" = {
        proxyPass = "http://localhost:8897/";
        extraConfig =
          nginxLocationWagtailExtraConfig
          + ''
            if ($host != 'wagtail.village.ong') {
              return 301 $scheme://wagtail.cfran.org$request_uri;
            }
          '';
      };
      # extraConfig = ''
      #   if ($host != 'wagtail.village.ong') {
      #     return 301 $scheme://wagtail.cfran.org$request_uri;
      #   }
      # '';
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/medias" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "django.village.ngo" = {
      enableACME = true;
      serverAliases = [
        # "django.fastoche.org"
        # "django.cfran.org"
        "django.village.ong"
        # "django.villagengo.com"
        # "django.villagengo.org"
      ];
      # extraConfig = ''
      #   if ($host != 'django.cfran.org') {
      #     return 301 $scheme://django.cfran.org$request_uri;
      #   }
      # '';
      forceSSL = true;
      root = "/var/www/django-village/";
      locations."/" = {
        proxyPass = "http://localhost:8891/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "fabrique.village.ngo" = {
      enableACME = true;
      forceSSL = true;
      serverAliases = [
        # "designsystem.fastoche.org"
        "designsystem.village.ngo"
        # "designsystem.cfran.org"
        # "designsystem.village.ong"
        # "designsystem.villagengo.com"
        # "designsystem.villagengo.org"
      ];
      # extraConfig = ''
      #   if ($host != 'designsystem.cfran.org') {
      #     return 301 $scheme://designsystem.cfran.org$request_uri;
      #   }
      # '';
      root = "/var/www/designsystem-village/";
      # locations."/" = {
      #   proxyPass = "http://localhost:8891/";
      #   extraConfig = nginxLocationWagtailExtraConfig;
      # };
      # locations."/favicon.ico" = { proxyPass = null; };
      # locations."/static" = { proxyPass = null; };
      # locations."/example" = { proxyPass = null; };
      # locations."/medias" = { proxyPass = null; };
      # locations."/.well-known" = { proxyPass = null; };
    };
    "meet.lesgv.org" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = [
        "meet.village.ngo"
        "meet.village.ong"
        "meet.villagengo.com"
        "meet.villagengo.org"
      ];
      enableACME = true;
      forceSSL = true;
      root = "/var/www/wagtail/";
      # root = "/var/www/coopgv/";
      locations."/" = {
        proxyPass = "http://localhost:8008/";
        # proxyPass = "http://localhost:8904/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/medias" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "8895.lesgrandsvoisins.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = ["8895.grandsvoisins.com"];
      enableACME = true;
      forceSSL = true;
      root = "/var/www/villagengo/";
      locations."/" = {
        proxyPass = "http://localhost:8895/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/medias" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    # "meet.desgv.com"  = {
    #   enableACME = true;
    #   forceSSL = true;
    #   globalRedirect = "meet.resdigita.com";
    # };
    "gvoisin.resdigita.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = [
        # "meet.lesgrandsvoisins.com"
        "discourse.resdigita.com"
        "meet.village.ngo"
        "meet.village.ong"
        # "jswiki.resdigita.com"
        # "gvoisin.desgrandsvoisins.org"
        #  "gvoisin.desgrandsvoisins.com"
        #  "gvoisin.lesgrandsvoisins.com"
        #  "gvoisin.desgv.com"
        #  "gvoisin.lesgv.com"
      ];
      enableACME = true;
      forceSSL = true;
      root = "/var/www/wagtail/";
      # root = "/var/www/coopgv/";
      locations."/" = {
        #proxyPass = "http://10.245.101.15:8080";
        proxyPass = "http://localhost:8008/";
        # proxyPass = "http://localhost:8904/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/medias" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };

    "wagtail.lesgv.org" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = [
        "www.lesartsvoisins.com"
        "lesartsvoisins.com"
        # "publicinter.org"
        # "www.publicinter.org"
        # "publicinter.net"
        # "www.publicinter.net"
        # "www.coopgv.com"
        # "coopgv.com"
        "www.coopgv.org"
        "www.gvcoop.com"
        # "gv.coop"
        # "www.gv.coop"
        # "wagtail.gv.coop"
        # "wagtail.lesgv.org"
      ];
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:8008/";
        # proxyPass = "http://localhost:8904/";
        extraConfig =
          nginxLocationWagtailExtraConfig
          + ''
            if ($host = 'gv.coop') {
                return 301 $scheme://www.$host$request_uri;
            }
          '';
      };
      root = "/var/www/wagtail/";
      # root = "/var/www/coopgv/";
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/medias" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
      # extraConfig = ''
      #   if ($host = 'gv.coop') {
      #       return 301 $scheme://www.$host$request_uri;
      #   }
      # '';
    };

    "apostrophecms.resdigita.com" = {
      extraConfig = "# proxy_protocol off;";
      root = "/var/www/wagtail/";
      # root = "/var/www/coopgv/";
      serverAliases = [
        "manncoach.resdigita.com"
        "resdigitacom.resdigita.com"
        "distractivescom.resdigita.com"
        "whowhatetccom.resdigita.com"
        "coopgvcom.resdigita.com"
        "popuposcom.resdigita.com"
        "grandsvoisinscom.resdigita.com"
        "forumgrandsvoisinscom.resdigita.com"
        # "discoursewww.lesgv.com"
        # "discourse.lesgv.com"
        "discourse.resdigita.com"
        "lesgvcom.resdigita.com"
        "iriviorg.resdigita.com"
        "hyperattentioncom.resdigita.com"
        "forumgdvoisinscom.resdigita.com"
        "agoodvillagecom.resdigita.com"
        "configmagiccom.resdigita.com"
        "caplancitycom.resdigita.com"
        "quiquoietccom.resdigita.com"
        "lesartsvoisinscom.resdigita.com"
        "maelanccom.resdigita.com"
        "manncity.resdigita.com"
        "focusplexcom.resdigita.com"
        "vlgorg.resdigita.com"
        "oldlesgrandsvoisinscom.resdigita.com"
        "cooptellgv.resdigita.com"
        "howwownowcom.resdigita.com"
        "aaalesgrandsvoisinscom.resdigita.com"
        "oldmanndigital.resdigita.com"
        "resolvactivecom.resdigita.com"
        "gvcity.resdigita.com"
        "toutdouxlissecom.resdigita.com"
        "iciwowcom.resdigita.com"
        "apostrophecms.lesgv.org"
      ];
      enableACME = true;
      # sslCertificate = "/var/lib/acme/wagtail.resdigita.com/fullchain.pem";
      # sslCertificateKey = "/var/lib/acme/wagtail.resdigita.com/key.pem";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.245.101.15:8080/";
        extraConfig = nginxLocationWagtailExtraConfig;
        # extraConfig = ''
        #   proxy_set_header Host $host:$server_port;
        # '';
      };
      locations."/favicon.ico" = {
        proxyPass = "http://10.245.101.15:8898/favicon.ico";
      };
      locations."/static/" = {proxyPass = "http://wagtailstatic/";};
      locations."/media/" = {proxyPass = "http://wagtailmedia/";};
    };

    "lesgv.lesgrandsvoisins.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = ["2022.lesgrandsvoisins.com"];
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:8008/";
        # proxyPass = "http://localhost:8904/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/medias" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      root = "/var/www/wagtail/";
      # root = "/var/www/coopgv/";
    };

    "www.coopgv.org" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = [
        # "desgv.com"
        "francemali.lesgrandsvoisins.com"
        "www.shitmuststop.com"
        "www.coopgv.com"
        "ghost.resdigita.com"
        "listmonk.resdigita.com"
      ];
      enableACME = true;
      # sslCertificate = "/var/lib/acme/www.lesgrandsvoisins.fr/fullchain.pem";
      # sslCertificateKey = "/var/lib/acme/www.lesgrandsvoisins.fr/key.pem";
      # sslTrustedCertificate = "/var/lib/acme/www.lesgrandsvoisins.fr/fullchain.pem";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:8008/";
        # proxyPass = "http://localhost:8904/";
        extraConfig =
          nginxLocationWagtailExtraConfig
          + ''
            if ($host = 'desgv.com') {
                return 301 $scheme://www.$host$request_uri;
            }
            if ($host = 'maelanc.com') {
                return 301 $scheme://www.$host$request_uri;
            }
            if ($host = 'francemali.com') {
                return 301 $scheme://www.$host$request_uri;
            }
            # if ($host  ~  /lesgv.org|lesgv.com|www.lesgv.com|www.lesgv.org|gv.coop|www.gv.coop|coopgv.com|coopgv.org|www.coopgv.com|www.coopgv.org/ ) {
            #     # return 301 $scheme://les.$host$request_uri;
            #     return 301
            # if ($host = 'lesgv.org') {
            #     return 301 $scheme://les.gv.coop$request_uri;
            # }
            # if ($host = 'www.lesgv.org') {
            #     return 301 $scheme://les.gv.coop$request_uri;
            # }
            # if ($host = 'lesgv.com') {
            #     return 301 $scheme://les.gv.coop$request_uri;
            # }
            # if ($host = 'www.lesgv.com') {
            #     return 301 $scheme://les.gv.coop$request_uri;
            # }
            # if ($host = 'gv.coop') {
            #     return 301 $scheme://www.gv.coop$request_uri;
            # }
            # if ($host = 'www.gv.coop') {
            #     return 301 $scheme://les.gv.coop$request_uri;
            # }
            if ($host = 'lesgrandsvoisins.fr') {
                # return 301 $scheme://www.lesgrandsvoisins.com;
                return 301 $scheme://www.lesgrandsvoisins.fr$request_uri;
            }
            # if ($host = 'www.lesgrandsvoisins.fr') {
            #     return 301 $scheme://www.lesgrandsvoisins.com;
            #     # return 301 $scheme://www.lesgrandsvoisins.com$request_uri;
            # }
          '';
      };
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/medias" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      root = "/var/www/wagtail/";
      # root = "/var/www/coopgv/";
    };
    # "www.desgrandsvoisins.org" = {
    #   serverAliases = ["desgrandsvoisins.org"  "desgrandsvoisins.com" "www.desgrandsvoisins.com"];
    #   globalRedirect = "www.lesgrandsvoisins.com";
    #    enableACME = true;
    #    forceSSL = true;
    # };
    "www.l-g-v.com" = {
      serverAliases = ["www.l-g-v.org"];
      # sslCertificateKey = "/etc/ssl/lesgrandsvoisins.com.key";
      # sslCertificate = "/etc/ssl/lesgrandsvoisins.com.crt";
      # sslTrustedCertificate = "/etc/ssl/lesgrandsvoisins.com.ca-bundle";
      enableACME = true;
      forceSSL = true;
      globalRedirect = "www.lesgrandsvoisins.com";
    };
    # "lesgrandsvoisins.com" = {
    #   # sslCertificateKey = "/etc/ssl/lesgrandsvoisins.com.key";
    #   # sslCertificate = "/etc/ssl/lesgrandsvoisins.com.crt";
    #   # sslTrustedCertificate = "/etc/ssl/lesgrandsvoisins.com.ca-bundle";
    #   enableACME = true;
    #   forceSSL = true;
    #   globalRedirect = "www.lesgrandsvoisins.com";
    # };
    "older.lesgrandsvoisins.com" = {
      extraConfig = "# proxy_protocol off;";
      # serverAliases = ["lesgrandsvoisins.com"];
      # sslCertificateKey = "/etc/ssl/lesgrandsvoisins.com.key";
      # sslCertificate = "/etc/ssl/lesgrandsvoisins.com.crt";
      # sslTrustedCertificate = "/etc/ssl/lesgrandsvoisins.com.ca-bundle";
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:8008/";
        # proxyPass = "http://localhost:8904/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      root = "/var/www/wagtail/";
      # root = "/var/www/coopgv/";
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/medias" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "www.maelanc.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = ["irivi.maelanc.com"];
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:8008/";
        # proxyPass = "http://localhost:8904/";
        extraConfig =
          nginxLocationWagtailExtraConfig
          + ''
            # return 302 https://maelnemacherif.wixsite.com/anc1;
            if ($host = 'maelanc.com') {
              return 302 https://maelnemacherif.wixsite.com/anc1;
            #     return 301 $scheme://www.$host$request_uri;
            }
            if ($host = 'www.maelanc.com') {
              return 302 https://maelnemacherif.wixsite.com/anc1;
            #     return 301 $scheme://www.$host$request_uri;
            }
          '';
      };
      root = "/var/www/wagtail/";
      # root = "/var/www/coopgv/";
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/medias" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "mann.fr" = {
      enableACME = true;
      forceSSL = true;
      globalRedirect = "www.mann.fr";
    };
    "www.mann.fr" = {
      enableACME = true;
      forceSSL = true;
      serverAliases = ["meet.mann.fr"];
      locations."/" = {
        proxyPass = "http://localhost:8008/";
        # proxyPass = "http://localhost:8904/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      root = "/var/www/wagtail/";
      # root = "/var/www/coopgv/";
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/medias" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "paris14.village.ngo" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/village/";
      locations."/" = {
        proxyPass = "http://localhost:8896/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      # extraConfig = ''
      #   if ($host != 'wagtail.village.ngo') {
      #     return 301 $scheme://wagtail.cfran.org$request_uri;
      #   }
      # '';
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/medias" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "8008.lesgrandsvoisins.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = ["8008.grandsvoisins.com"];
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:8008/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      root = "/var/www/wagtail/";
      # root = "/var/www/coopgv/";
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/medias" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "8893.lesgrandsvoisins.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = ["8893.grandsvoisins.com"];
      root = "/var/www/www-fastoche/";
      locations."/" = {
        proxyPass = "http://localhost:8893/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME = true;
      forceSSL = true;
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "8892.lesgrandsvoisins.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = ["8892.grandsvoisins.com"];
      root = "/var/www/resdigita-fastoche/";
      locations."/" = {
        proxyPass = "http://localhost:8892/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME = true;
      forceSSL = true;
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "8890.lesgrandsvoisins.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = ["8890.grandsvoisins.com"];
      root = "/var/www/wagtail-fastoche/";
      locations."/" = {
        proxyPass = "http://localhost:8890/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME = true;
      forceSSL = true;
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "8894.lesgrandsvoisins.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = ["8894.grandsvoisins.com"];
      root = "/var/www/lesgrandsvoisins/";
      locations."/" = {
        proxyPass = "http://localhost:8894/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME = true;
      forceSSL = true;
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "8904.lesgrandsvoisins.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = ["8904.grandsvoisins.com"];
      root = "/var/www/coopgv/";
      locations."/" = {
        proxyPass = "http://localhost:8904/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME = true;
      forceSSL = true;
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "8905.lesgrandsvoisins.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = ["8905.grandsvoisins.com"];
      root = "/var/www/wagtailgvcoop/";
      locations."/" = {
        proxyPass = "http://localhost:8905/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME = true;
      forceSSL = true;
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "8906.lesgrandsvoisins.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = ["8906.grandsvoisins.com"];
      root = "/var/www/wagtail-lesgrandsvoisinscom/";
      locations."/" = {
        proxyPass = "http://localhost:8906/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME = true;
      forceSSL = true;
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "8888.lesgrandsvoisins.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = ["8888.grandsvoisins.com"];
      root = "/var/www/francemali/";
      locations."/" = {
        proxyPass = "http://localhost:8888/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME = true;
      forceSSL = true;
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "8896.lesgrandsvoisins.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = ["8896.grandsvoisins.com"];
      root = "/var/www/village/";
      locations."/" = {
        proxyPass = "http://localhost:8896/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME = true;
      forceSSL = true;
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "8900.lesgrandsvoisins.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = ["8900.grandsvoisins.com"];
      root = "/var/www/cantine/";
      locations."/" = {
        proxyPass = "http://localhost:8900/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME = true;
      forceSSL = true;
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "8889.lesgrandsvoisins.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = ["8889.grandsvoisins.com"];
      root = "/var/www/cfran/";
      locations."/" = {
        proxyPass = "http://localhost:8889/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME = true;
      forceSSL = true;
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "8897.lesgrandsvoisins.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = ["8897.grandsvoisins.com"];
      root = "/var/www/resdigita-fastoche/";
      locations."/" = {
        proxyPass = "http://localhost:8897/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME = true;
      forceSSL = true;
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "8899.lesgrandsvoisins.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = ["8899.grandsvoisins.com"];
      root = "/var/www/resdigitaorg/";
      locations."/" = {
        proxyPass = "http://localhost:8899/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME = true;
      forceSSL = true;
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "8891.lesgrandsvoisins.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = ["8891.grandsvoisins.com"];
      root = "/var/www/django-village/";
      locations."/" = {
        proxyPass = "http://localhost:8891/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME = true;
      forceSSL = true;
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "wagtailnews.resdigita.com" = {
      extraConfig = "# proxy_protocol off;";
      root = "/var/www/wagtail.resdigita.com/";
      locations."/" = {
        proxyPass = "http://localhost:8902/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME = true;
      forceSSL = true;
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "wagtail.resdigita.com" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = ["www.resdigita.com"];
      root = "/var/www/wagtail.resdigita.com.main/";
      locations."/" = {
        proxyPass = "http://localhost:8903/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME = true;
      forceSSL = true;
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "develop.resdigita.com" = {
      extraConfig = "# proxy_protocol off;";
      root = "/var/www/wagtail.resdigita.com.develop/";
      locations."/" = {
        proxyPass = "http://localhost:8910/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME = true;
      forceSSL = true;
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
    "www.grandzine.org" = {
      extraConfig = "# proxy_protocol off;";
      serverAliases = [
        "8909.grandsvoisins.com"
        "www.grandv.org"
      ];
      root = "/var/www/grandv/";
      locations."/" = {
        proxyPass = "http://localhost:8909/";
        extraConfig = nginxLocationWagtailExtraConfig;
      };
      enableACME = true;
      forceSSL = true;
      locations."/favicon.ico" = {proxyPass = null;};
      locations."/static" = {proxyPass = null;};
      locations."/media" = {proxyPass = null;};
      locations."/.well-known" = {proxyPass = null;};
    };
  };
}
