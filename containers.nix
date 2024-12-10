{ config, pkgs, lib, ... }:
let
  # seafilePassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.seafile));
  home-manager = import ../vars/home-manager.nix;
  my-python-packages = import ../vars/my-python-packages.nix;
  home-mannchriRsaPublic = import ../vars/mannchri-rsa-public.nix;
  home-manager2305 = builtins.fetchTarball { url="https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz"; sha256="sha256:00wp0s9b5nm5rsbwpc1wzfrkyxxmqjwsc1kcibjdbfkh69arcpsn"; };
  hasaeraRsaPublic = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAuBWybYSoR6wyd1EG5YnHPaMKE3RQufrK7ycej7avw3Ug8w8Ppx2BgRGNR6EamJUPnHEHfN7ZZCKbrAnuP3ar8mKD7wqB2MxVqhSWvElkwwurlijgKiegYcdDXP0JjypzC7M73Cus3sZT+LgiUp97d6p3fYYOIG7cx19TEKfNzr1zHPeTYPAt5a1Kkb663gCWEfSNuRjD2OKwueeNebbNN/OzFSZMzjT7wBbxLb33QnpW05nXlLhwpfmZ/CVDNCsjVD1+NXWWmQtpRCzETL6uOgirhbXYW8UyihsnvNX8acMSYTT9AA3jpJRrUEMum2VizCkKh7bz87x7gsdA4wF0/w== rsa-key-20220407";
  ldapDomainName = "ldap.gv.coop";
  lgvLdapDomainName = import vars/lgv-ldap-domain-name.nix;
  ldapBaseDN = "dc=gv,dc=coop";
  lgvLdapBaseDN = import vars/lgv-ldap-base-dn.nix;
  # bindPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bind));
  # alicePassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.alice));
  # bobPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.bob));
  # sogoPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.sogo));
  # oauthPassword = (lib.removeSuffix "\n" (builtins.readFile /etc/nixos/.secrets.oauthpassword));
  # domainName = "mail.gv.coop";
  bindSlappasswd = import secrets/bind.slappasswd;
  domainName = "mail.lesgrandsvoisins.com";
  whitelistSubnets =  import vars/whitelist-subnets.nix;
  mailServerDomainAliases = import vars/mailserver-domain-aliases.nix;
in
{
  networking = {
    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "eno1";
      # Lazy IPv6 connectivity for the container
      enableIPv6 = true;
    };
  };
  imports = [
    ./containers/cherryldap.nix
    ./containers/discourse.nix
    ./containers/key.nix
    ./containers/keycloak.nix
    ./containers/lgvldap.nix
    ./containers/openldap.nix
    ./containers/silverbullet.nix
    ./containers/wagtail.nix
    ./containers/wordpress.nix
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