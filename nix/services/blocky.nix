{ config, pkgs, ... }:

{
  # Blocky adblocker
  services.blocky = {
    settings = {
      ports.dns = 53;
      upstreams.groups.default = [
        "127.0.0.1:5335"
      ];
      bootstrapDns = [
        "1.1.1.1"
        "1.1.1.2"
      ];
      blocking = {
        blockType = "nxDomain";
        denylists.ads = [
          "https://big.oisd.nl/"
          "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/pro.txt"
          "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
        ];
        clientGroupsBlock.default = [ "ads" ];
      };
      queryLog.type = "console";
      log.level = "info";
    };
  };
}