{ config, pkgs, ... }:

{
  services.samba = {
    settings = {
      global = {  
        "security" = "user";
        "workgroup" = "WORKGROUP";
        "server string" = "NAS";
        "map to guest" = "Bad User";
        
        "hosts allow" = "${config.sops.secrets.localNetworkCIDR} ${config.sops.secrets.tailnetCIDR}";
        "log file" = "/var/log/samba/log.%m";
        "max log size" = 1000;
        "logging" = "file";
        "disable netbios" = "yes";
        
        "bind interfaces only" = "yes";
        "interfaces" = "${config.sops.secrets.tailnetCIDR} ${config.sops.secrets.localNetworkCIDR}/24";
        
        "min receivefile size" = 16384;
        "getwd cache" = "yes";
        "use sendfile" = "yes";
      };
      nas = {
        path = "/mnt/nas";
        browseable = "no";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = config.sops.secrets.mainUser; 
        "force user" = config.sops.secrets.mainUser;
        "force group" = "users";
        "create mask" = "0664";
        "directory mask" = "0775";
      };
    };
  };
  systemd.services.smbd.after = [ "mnt-nas.mount" ];
  systemd.services.smbd.requires = [ "mnt-nas.mount" ];
}