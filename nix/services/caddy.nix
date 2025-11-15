{ config, ... }:

{
 services.caddy = {
    # host list and params
    virtualHosts = {
      "proxmox.${localDomain}" = {
        extraConfig = ''
          tls internal
          reverse_proxy https://${proxmoxStaticIp}:8006 {
            transport http {
                tls_insecure_skip_verify
            }
          }
        '';
      };
    };
  };
}