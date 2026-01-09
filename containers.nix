{
  config,
  pkgs,
  lib,
  ...
}: let
  # seafilePassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.seafile));
  # home-manager = import ../vars/home-manager.nix;
  my-python-packages = import ../vars/my-python-packages.nix;
  home-mannchriRsaPublic = import ../vars/mannchri-rsa-public.nix;
  # home-manager2305 = builtins.fetchTarball { url="https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz"; sha256="sha256:1rj0cazl5kjcfn4433fj31293yx421wbawryp5q3bq3fsmhkkr9h"; };
  # hasaeraRsaPublic = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAuBWybYSoR6wyd1EG5YnHPaMKE3RQufrK7ycej7avw3Ug8w8Ppx2BgRGNR6EamJUPnHEHfN7ZZCKbrAnuP3ar8mKD7wqB2MxVqhSWvElkwwurlijgKiegYcdDXP0JjypzC7M73Cus3sZT+LgiUp97d6p3fYYOIG7cx19TEKfNzr1zHPeTYPAt5a1Kkb663gCWEfSNuRjD2OKwueeNebbNN/OzFSZMzjT7wBbxLb33QnpW05nXlLhwpfmZ/CVDNCsjVD1+NXWWmQtpRCzETL6uOgirhbXYW8UyihsnvNX8acMSYTT9AA3jpJRrUEMum2VizCkKh7bz87x7gsdA4wF0/w== rsa-key-20220407";
  #   ldapDomainName = "ldap.gv.coop";
  ldapDomainName = "ldap.lesgrandsvoisins.com";
  lgvLdapDomainName = import vars/lgv-ldap-domain-name.nix;
  # ldapBaseDN = "dc=gv,dc=coop";
  ldapBaseDN = "dc=lesgrandsvoisins,dc=com";
  lgvLdapBaseDN = import vars/lgv-ldap-base-dn.nix;
  # bindPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bind));
  # alicePassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.alice));
  # bobPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bob));
  # sogoPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.sogo));
  # oauthPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.oauthpassword));
  # domainName = "mail.gv.coop";
  bindSlappasswd = import secrets/bind.slappasswd;
  domainName = "mail.lesgrandsvoisins.com";
  whitelistSubnets = import vars/whitelist-subnets.nix;
  mailServerDomainAliases = import vars/mailserver-domain-aliases.nix;
in {
  networking = {
    networkmanager.unmanaged = ["interface-name:ve-*"];
    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "eno1";
      # Lazy IPv6 connectivity for the container
      enableIPv6 = true;
    };
    bridges.br0.interfaces = ["eno1" "ve-key@if2"];
    # Name in key ve-key@if2
    useDHCP = false;
    # interfaces."br0".useDHCP = true;
    # interfaces."br0".ipv4.addresses = [{
    # address = "192.168.100.3";
    #   prefixLength = 24;
    # }];
    # defaultGateway = "192.168.100.1";
    # nameservers = [ "192.168.100.1" ];
  };
  imports = [
    ./containers/cherryldap.nix
    ./containers/wikijs.nix
    ./containers/discourse.nix
    ./containers/mattermost.nix
    ./containers/discourseparis14cc.nix
    ./containers/key.nix
    # ./containers/keycloak.nix
    ./containers/keyresdigita.nix
    ./containers/keycloakparis14cc.nix
    ./containers/keycloakgvoiscom.nix
    ./containers/keycloakgdvox.nix
    ./containers/keycloakparisgv.nix
    ./containers/keycloaklesgv.nix
    # ./containers/keycloakparisle.nix
    # ./containers/roundcuberesdigita.nix
    ./containers/vikunjaresdigita.nix
    ./containers/lgvldap.nix
    ./containers/openldap.nix
    ./containers/silverbullet.nix
    ./containers/triliumnext.nix
    ./containers/wagtail.nix
    ./containers/wordpress.nix
    ./containers/haproxy.nix
  ];
  # age.secrets = {
  #   "kopia.silverbullet" = {
  #     file = secrets/kopia.silverbullet.age;
  #     owner = "silverbullet";
  #   };
  #   # "bind.slappasswd" = { file = secrets/bind.slappasswd.age;};
  # };
  # networking.interfaces.vlan2 = {
  #   virtual = true;
  #   ipv4.addresses = [
  #     { address="192.168.102.1"; prefixLength=24; }
  #   ];
  #   ipv6.addresses = [
  #     { address="fc00::2:1"; prefixLength=112; }
  #   ];
  # };
}
