{
  gid = {
    caddy = 239;
    users = 100;
    services = 500;
    radicale = 504;
    named = 989;
  };
  uid = {
    caddy = 239;
    homarr = 1002; # Ce n'est plus utilisé
    mael = 1003;
    mannchri = 1000;
    lldap = 501;
    wiki-js = 502;
    keycloak = 503;
    radicale = 504;
    syncin = 1505;
    named = 991;
  };
  ports = {
    postgresql = 5434;
    wiki-js-www-https = 3443;
    wiki-js-www-http = 3480;
    wiki-js-libregood-https = 3445;
    wiki-js-libregood-http = 3482;
    wiki-js-doc-https = 3444;
    wiki-js-doc-http = 3481;
    redis-services-homarr = 6379;
    lldap-ldaps = 3636;
    lldap-http = 17170;
    lldap-ldap = 3890;
    radicale = 5232;
    radicale-public = 5252;
    xandikos = 10888;
  };
  ips.wiki-js = "::1";
  domains.wiki-js = "wiki.ggvv.org";
  hetzner.interfaces = [
    {
      mac = "90:1b:0e:9e:ec:37";
    }
  ];
  hetzner.ipv4 = [
    {
      interface = "enx901b0e9eec37";
      addr = "213.239.216.138";
      gw = "213.239.216.159";
      netmask = "27";
    }
    {
      addr = "213.239.217.187";
      gw = "213.239.217.161";
      netmask = "27";
    }
  ];
  hetzner.ipv6 = [
    {
      addr = "2a01:4f8:a0:73ba::";
      gw = "fe80::1";
      netmask = 64;
    }
    {
      addr = "2a01:4f8:a0:73ba::1";
      gw = "fe80::1";
      netmask = 64;
    }
    {
      addr = "2a01:4f8:a0:73ba::2";
      gw = "fe80::1";
      netmask = 64;
    }
    {
      addr = "2a01:4f8:a0:73ba::3";
      gw = "fe80::1";
      netmask = 64;
    }
    {
      addr = "2a01:4f8:a0:73ba::4";
      gw = "fe80::1";
      netmask = 64;
    }
    {
      addr = "2a01:4f8:a0:73ba::5";
      gw = "fe80::1";
      netmask = 64;
    }
    {
      addr = "2a01:4f8:a0:73ba::6";
      gw = "fe80::1";
      netmask = 64;
    }
    {
      addr = "2a01:4f8:a0:73ba::7";
      gw = "fe80::1";
      netmask = 64;
    }
    {
      addr = "2a01:4f8:a0:73ba::8";
      gw = "fe80::1";
      netmask = 64;
    }
    {
      addr = "2a01:4f8:a0:73ba::9";
      gw = "fe80::1";
      netmask = 64;
    }
  ];
  hetzner.interface = "enp0s31f6";
}
