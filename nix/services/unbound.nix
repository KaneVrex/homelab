{ config, ... }:

{
 services.unbound = {
    enable = true;
    settings = {
      server = {
        # listens locally on port 5335 for Pi-hole exclusively
        interface = [ "127.0.0.1" ];
        port = 5335;
        access-control = [ "127.0.0.1/32 allow" ];
        # define local network fixed names
        "local-zone" = ''"${localDomain}." static'';
        "local-data" = [
          ''"pi-server.${localDomain}. IN A ${serverStaticIP}"''
          ''"nas.${localDomain}. IN A ${serverStaticIP}"''
          ''"proxmox.${localDomain}. IN A ${serverStaticIP}"''
        ];
        "local-data-ptr" = [
          ''"${serverStaticIP} pi-server.${localDomain}."''
          ''"${proxmoxStaticIp} proxmox.${localDomain}."''
        ];
      };
    };
  };
}