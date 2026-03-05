{
  uid = {
    syncin = 1505;
    seafile = 1506;
    named = 991;
    gitea = 1509;
    forgejo = 1510;
  };
  gid = {
    users = 100;
    services = 500;
    named = 989;
  };
  ports = {
    syncin-http = 5080;
    syncin-https = 5443;
    gitea-https = 3446;
    gitea-ssh = 3022;
    forgejo-https = 3447;
    forgejo-ssh = 3222;
  };
  ip4s = {
    syncin = "127.0.0.1";
  };
  ip6s = {
    syncin = "::1";
    hosts = [
      "2a01:e0a:f4e:5880::1000"
      "2a01:e0a:f4e:5880::1001"
      "2a01:e0a:f4e:5880::1002"
      "2a01:e0a:f4e:5880::1003"
      "2a01:e0a:f4e:5880::1004"
      "2a01:e0a:f4e:5880::1005"
      "2a01:e0a:f4e:5880::1006"
      "2a01:e0a:f4e:5880::1007"
      "2a01:e0a:f4e:5880::1008"
      "2a01:e0a:f4e:5880::1009"
    ];
  };
}
