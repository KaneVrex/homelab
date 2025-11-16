{ config, pkgs, lib, inputs, ... }:

let

# Imports

  # Secrets management - do not share! 
  secrets = import ./secrets/secrets.nix;

# Variables forward declaration

  # Main user name 
  mainUser = secrets.mainUser;
  
  # Network configuration Variables
  serverStaticIP = secrets.serverStaticIP;
  localNetworkCIDR = secrets.localNetworkCIDR;
  proxmoxStaticIp = secrets.proxmoxStaticIp;
  tailnetCIDR = secrets.tailnetCIDR;
  defaultGatewayIP = secrets.defaultGatewayIP;

  # .lab
  localDomain = secrets.localDomain;
  
in
{

# Bootloader & Filesystem 

  # Limits the boot menu to the 3 latest generations and protects from removing by gc
  boot.loader.raspberryPi.configurationLimit = 3;

  # Ensure the kernel loads nvme and ntfs drivers
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" ];
  
  # Partiotion declaration
  fileSystems = {
    # Boot (nvme0n1p1)
    "/boot/firmware" = {
      device = lib.mkForce "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = [ "defaults" "noatime" ];
    };

    # Root (nvme0n1p2)
    "/" = {
      device = lib.mkForce "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4"; 
      options = [ "noatime" ];
    };

    # Nas share (nvme1n1p1)
      "/mnt/nas" = {
        device = "/dev/disk/by-label/NAS";
        fsType = "ext4"; 
        options = [ "defaults" "nofail" "noatime" "nodiratime" ]; 
      };
  };

  # swapfile on the root nvme
  swapDevices = [{
      device = "/swapfile";
      size = 8 * 1024; # 8GB  
    }];

  # Controll swap agresiveness
  # Disable IPv6
  # enabel IP forwarding for tailscale network 
  boot.kernel.sysctl = {    
    "vm.swappiness" = 30; 
    "net.ipv4.ip_forward" = 1; 
    "net.ipv6.conf.all.disable_ipv6" = 1;
    "net.ipv6.conf.default.disable_ipv6" = 1;
    "net.ipv6.conf.lo.disable_ipv6" = 1;
  };
  
# Identity & Base Settings

  # Machine name
  networking.hostName = "pi-server"; 
  time.timeZone = "Europe/Kyiv";
  system.stateVersion = "25.05";
  
  # Nix Garbage Collection for maintenance
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d"; # Delete generations older than one week
  };

  # Users & Permissions
  users.mutableUsers = false; 
  
  # main user definition
  users.users.${mainUser} = {
      isNormalUser = true;
      description = "Main User";
      extraGroups = [ "wheel" "tailscale" ]; 
      initialHashedPassword = secrets.mainUserHashedPassword; 
      openssh.authorizedKeys.keys = [ secrets.mainUserSshPublicKey ];
    };
      
# Packages & Tools
  
  # packages installed on nixos-rebuild switch
  environment.systemPackages = with pkgs; [
    git wget curl htop
    openssh
    nano       
    tailscale
    rsync
    nssTools
  ];

# Networking & Firewall

  networking.useDHCP = false;
  networking.interfaces.end0.ipv4.addresses = [
    { address = serverStaticIP; prefixLength = 24; }
  ];
  networking.defaultGateway = defaultGatewayIP;
  # add primaty nameserver when unbound is up "127.0.0.1"
  # cloudflare as redundancy
  networking.nameservers = [ "127.0.0.1" "1.1.1.1" ]; 
   
  # use updated nftables firewall instead of iptables
  networking.nftables.enable = true;

  networking.firewall = {
    enable = true;
    allowPing = false;
    checkReversePath = "loose";
    trustedInterfaces = [ "lo" config.services.tailscale.interfaceName ]; 
    
    # Allow unrestricted access only from local network
    extraInputRules = ''
      ip saddr ${localNetworkCIDR} accept
    '';
    
    # expose specific ports for services
    # Ports: 139/445(Samba), 80/443(Caddy), 53(DNS)
    allowedTCPPorts = [ ]; 
    # tailscale needs to be included here
    # Ports: 53(DNS), 41641(Tailscale)
    allowedUDPPorts = [ 41641 ]; 
  };

  # Disable WiFi, BT drivers, audio modules, sd_card, cd-rom
  boot.blacklistedKernelModules = [ 
    "brcmfmac" "brcmutil" "btusb" "snd_bcm2835" "pcspkr" 
  ];  

# System Services

  # OpenSSH Service
  services.openssh = {
      enable = true;
      # Enforce key-only login
      # rpi5-flake allows password auth by default
      settings.PasswordAuthentication = false; 
    };

  # Tailscale external vpn service
  services.tailscale = {
    enable = true;
    # enable local network advertisment for tailnetwork
    # allows access to local network for devices on tailnetwork throu pi-server
    extraUpFlags = [
      "--advertise-routes=${localNetworkCIDR}"
    ];
  };

  # Caddy reverse proxy
  services.caddy = {
    enable = true;

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

  # Unbound recursive DNS resolver
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

  # Blocky adblocker
  services.blocky = {
    enable = true;
    settings = {

      # listen to all interfaces
      ports.dns = 53;

      # use unbound as only default dns resolver
      upstreams.groups.default = [ "127.0.0.1:5335" ];

      # fallback dns
      bootstrapDns = [ "1.1.1.1" "1.1.1.2" ];

      blocking = {
        # block responce
        blockType = "nxDomain";

        # blocklists
        denylists = {
          ads = [
            "https://big.oisd.nl/"
            "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/pro.txt"
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
          ];
        };

        # defaul block group
        clientGroupsBlock = {
          default = [ "ads" ];
        };
      };
      # logging for journalctl
      queryLog.type = "console";
      log.level = "info";
    };
  };

  # Samba File Share
  services.samba = {
    enable = true;
    settings = {
      global = {
        security = "user";
        workgroup = "WORKGROUP";
        "server string" = "NAS";
        "map to guest" = "Bad User";
        # allow local network and tailscale users
        "hosts allow" = "${localNetworkCIDR} ${tailnetCIDR}";
        "log file" = "/var/log/samba/log.%m";
        "max log size" = 1000;
        logging = "file";
        # fail logins tracking for fail2ban
        # "log level" = "1 auth_audit:5";
        "disable netbios" = "yes";
        "bind interfaces only" = "yes";
        "interfaces" = "${tailnetCIDR} ${serverStaticIP}/24";
        # performance improvements
        "min receivefile size" = "16384";
        "getwd cache" = "yes";
        "use sendfile" = "yes";
      };

      nas = {
        path = "/mnt/nas";
        browseable = "no";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = mainUser;
        "force user" = mainUser;
        "force group" = "users";
        "create mask" = "0664";
        "directory mask" = "0775";
      };
    };
  };
  
  systemd.services.smbd.after = [ "mnt-nas.mount" ];
  systemd.services.smbd.requires = [ "mnt-nas.mount" ];

  # Automatic updates and rebuil with monthy cadence
  systemd.timers.nixos-monthly-rebuild = {
    wantedBy = [ "timers.target" ];
    timerConfig = { OnCalendar = "Mon *-*-1 02:00:00"; Persistent = true; };
  };

  systemd.services.nixos-monthly-rebuild = {
    description = "Monthly NixOS system upgrade and switch";
    after = [ "network.target" "mnt-nas.mount" ]; 
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --upgrade --flake /home/${mainUser}/nix_conf#${config.networking.hostName}";
      User = "root";
    };
  };
}
