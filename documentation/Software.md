## Devices

| Name                     | Machine name   | Host OS | Role                          | Local IP addr | main user              | Hosted services                                            |
| ------------------------ | -------------- | ------- | ----------------------------- | ------------- | ---------------------- | ---------------------------------------------------------- |
| Lenovo ThinkCentre M715q | proxmox-server | proxmox | Proxmox VM host, service host | 192.168.0.120 | PAM: root<br>PVE: kane | - Foundry<br>- DiscordBot<br>- Work VMs                    |
| Raspberry Pi  5 (RPI5)   | pi-server      | NixOS   | Service host, hub node        | 192.168.0.228 | kane                   | - Tailscale<br>- Caddy<br>- Unbound<br>- Blocky<br>- Samba |

### Lenovo ThinkCentre M715q
#### OS 
Proxmox version 8.4.1
Intended to host FRE and FC VMs for work
As well as other occasional services like Discord bot and Foundry 12 
[download link ](https://www.proxmox.com/en/downloads/proxmox-virtual-environment/iso/proxmox-ve-8-4-iso-installer)
WEB interface accessible from: 192.168.0.120:8006 or proxmox.lab if unbound is up.
Local network IP address is set to 192.168.0.120 and pinned to this machine mac on router side

Firewall rules restrict connection from outside of local network in the following manner: 
IP Set - defines allowed IP addresses
Current set "allowed" : 

| IP             | Comment                 |
| -------------- | ----------------------- |
| 100.64.0.0/10  | tailscale network       |
| 192.168.0.0/24 | local network           |
| 192.168.0.122  | main PC as a redundancy |

Security Group "default" :

| Type | Action | Source  | Comment                                |
| ---- | ------ | ------- | -------------------------------------- |
| IN   | ACCEPT | allowed | accepts connection from allowed ip set |
| IN   | DROP   | ---     | drops connection to everything else    |
==Note: order of rule application matters most, first accept then deny.== 

#### Storage 
| Name           | Type     | Content                    | Path                       | Shared | Enabled | Comment                                              |
| -------------- | -------- | -------------------------- | -------------------------- | ------ | ------- | ---------------------------------------------------- |
| local          | Dir      | Import                     | /var/lib/vz                | No     | No      | Local system root drive, not to be used for vm's     |
| samba_CT_pool  | SMB/CIFS | Backup, Container template | /mnt/pve/samba_CT_pool/OS  | Yes    | Yes     | Container tamplate and backup storage on samba share |
| samba_ISO_pool | SMB/CIFS | ISO image                  | /mnt/pve/samba_ISO_pool/OS | Yes    | Yes     | OS iso image pool located on samba share             |
| vm_pool_nvme   | LVM-Thin | Disk image,container       |                            | No     | Yes     | Host drive for local vm's and containers only.       |
The main idea is to separate ISO, CT storage from the actual machines preserving clean set up and ability to roll out any distro housed on samba.

#### Users
Consists of two user types PVE and PAM:
PAM user is defined in the system and can have access to both web interface and system shell and be default is only root. 
PVE user is user created in WEB and has access only to WEB interface. 

==Note: it is recommended security practice to leave root as only PAM user creating all others as PVE.==

Current active users: 
	root - PAM user
	kane - PVE admin user

Permissions defined for user "kane"
Group "admin" houses role Administrator which allows full control over WEB interface.   
Local VM users varies from machine to machine but usually it's either k.dolhov or kane with password 1111 due to irrelevance. 

#### Services, VMs
Consists of floating number of VM's and Containers, serving different purposes. 
Current set: 

| ID  | Name                | Type      | OS         | DE         | Purpose                                | Modifications                                                                                                                                                       | Comments                                                                                                                                                                                                                                                                                                                                               | IP                     | Users            | Password              |
| --- | ------------------- | --------- | ---------- | ---------- | -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------- | ---------------- | --------------------- |
| 100 | Windows-10-Original | VM        | Windows 10 | Windows 10 | image prepared for clonin              | - disabled telemetry<br>- performance improvements<br>- disabled windows spy services<br>- general debloating<br>- installed PDF tools, VS, Notepad<br>- Qemu guest | In case another Windows vm is needed I can just clone this image instead of creating a new one. Could've used templates bu I didn't know that home edition cannot be turned into template due to lack of cleaning tools on the system side. <br>DO NOT use Windows home for VM's anymore.<br>IP is set in setting and should be changed after clonning | 192.168.0.115          | k.dolhov         | 1111                  |
| 101 | Win.10.FRE12        | VM        | Windows 10 | Windows 10 | FRE12 Windows VM                       | Inherited from Windows-10-Original                                                                                                                                  | Windows 10 VM hosting FRE12 Windows and several snapshot of different version of it.                                                                                                                                                                                                                                                                   | 192.168.0.115          | k.dolhov         | 1111                  |
| 102 | Ubuntu.FRE12        | VM        | Ubuntu 24. | Gnome      | FRE12 Linux VM                         | - Enabled basic Gnome RDP<br>- installed required packages and compilers, VS code, OnlyOffice                                                                       | Ubuntu 10 VM hosting FRE12 Linux and several snapshot of different version of it.                                                                                                                                                                                                                                                                      | 192.168.0.105          | k.dolhov<br>root | 1111<br>1111          |
| 103 | Win.10.FC.SDK       | VM        | Windows 10 | Windows 10 | FC SDK Windows VM                      | Inherited from Windows-10-Original                                                                                                                                  | Windows 10 VM hosting FC SDK Windows and several snapshot of different version of it.                                                                                                                                                                                                                                                                  | 192.168.0.125          | k.dolhov         | 1111                  |
| 104 | debian.foundry.host | VM        | Debian     | Headless   | Hosting Foundry VTT on local server    | - Installed PM2 <br>- boot on startup<br>- samba share created on top of Foundry user data folder                                                                   | Product of this guide:  [link](https://foundryvtt.wiki/en/setup/linux-installation)<br>Intended to host Lancer on Foundry 12 until the module updates<br>                                                                                                                                                                                              | 192.168.0.160          | artem<br>root    | LancerFounder<br>marc |
| 105 | Debian.FRE12        | VM        | Debian     | XFCE       | Experimental VM for FRE12 with FXCE DE | - Lightveight DE<br>- additional optimization<br>- Enabled RPD to XFCE session                                                                                      | VM Experiment, it is expected that XFCE and X11 session with RDP will provide better performance results in comparison with Ubuntu Gnome                                                                                                                                                                                                               | 192.168.0.135          | kane<br>root     | 1111<br>1111          |
| 106 | discord.bot.red     | Container | Debian     | Headless   | Hosting discord music bot              | - Bot variables<br>- Aliases - copied from folder in sessing.json<br>- additional cogs<br>                                                                          | A results of debian container template only needed to host a set bot: [link](https://github.com/PhasecoreX/docker-red-discordbot)<br>                                                                                                                                                                                                                  | <br>host 192.168.0.228 | root             | 1111                  |

Connect using Remmina RDP 
Baseline settings for VM's  for maximum performance, same for both types of OS

| General          | OS        | System                                                                                                     | Disks                                                                     | CPU                                    | RAM                           | Network    |
| ---------------- | --------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- | -------------------------------------- | ----------------------------- | ---------- |
| Nothing specific | ISO Image | Graphics card - none<br>Machine  - q35<br>Bios - OVMF(UEFI)<br>Qemu Agent - Check<br>Disable EFI disk <br> | Bus - SCSI<br>IO thread - On<br>Discard - On<br>Cache - No<br>Backup - No | Type - host<br>Socket - 1<br>Cores - 6 | 6x1024<br>Ballooning - On<br> | Keep as is |
- RAM-Ballooning - questionable option can be disabled for max performance of single VM, but recommended to keep on for long run on lover ram machine.  
- System-Graphics card - optimal way is to disable graphics completely and use RDP session saving rousrces, turn back on to troubleshoot connection issues or direct access from WEB.
- Network - unfortunately there is no option to set up IP addr before first launch thus not specific settings. Also can use multique if multiple users need to access the machine at once. 
- IP Addr - naming convention for IP of VMs something that ends with 5 with margin of 10 .e.g: 105, 115, 125, 135, 145 available addresses reserved specifically for VMs for clarity.


#### VM Local Network
vmbr0 - bridge more VM network nothing specific at this time. 


### Raspberry Pi  5 (RPI5)

#### OS 
Using NixOS 25.05 Stable release as main OS configured from:

| Name              | Description                                                                   |
| ----------------- | ----------------------------------------------------------------------------- |
| configuration.nix | main configuration file controlling all system aspects.                       |
| flake.nix         | system build file, controls what and how should be build for the final image. |
| secrets.nix       | secret control file, consists of password and do not share data.              |
Due to RPI5 host additional flake was added to facilitate to hardware requirements:
```
# Use the maintained nvmd flake for rpi5 build
nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
```

##### Bootloader & Filesystem
Since Nix saves older configurations as generations it is vital to clean them up to preserve space, however also keep several latest as a backup option.
Current generation limit is 3. 
```
boot.loader.raspberryPi.configurationLimit = 3;
```
additionally supplied with garbage collector to help with cleaning\
```
nix.gc = {
	automatic = true;
	dates = "weekly";
	options = "--delete-older-than 7d"; # Delete generations older than one week
};
```
Ensuring that the system will load the required modules for NTFS and NVME drives: 
```
boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" ];
```
Initial plan was to define each partition UUID and bind the loader to it but after writing the system image with dd the UUID values were changed to default random.
Which lead naturally to binding via labels since they remain consistent throughout different system: 

| Name     | Description                                          |
| -------- | ---------------------------------------------------- |
| FIRMWARE | Bootloader partition where vfat data will be written |
| NIXOS_SD | Main system root partition                           |
| NAS      | Samba share partition on a separate drive            |
Additionally swap file is created to help with high RAM loads and  defined over the rebuild 
Aggressiveness is also specify to use swap only when RAM is 70% loaded. 

==Note: swap is not created during first install and build, only after rebuild.== 

| Swap      | Size     | Agressiveness |
| --------- | -------- | ------------- |
| /swapfile | 8 * 1024 | 30            |

##### Changed modules
Some modules are also disabled to reduce bloat and provide higher levels of security.
As well as enabled IPv4 Forwarding to help  with Tailscale network advertisement 

| Name                                      | Comment                                     |
| ----------------------------------------- | ------------------------------------------- |
| "net.ipv4.ip_forward" = 1;                | enables network advertisement for Tailscale |
| "net.ipv6.conf.all.disable_ipv6" = 1;     | disable IPv6 in all configs                 |
| "net.ipv6.conf.default.disable_ipv6" = 1; | disable IPv6 in default config              |
| "net.ipv6.conf.lo.disable_ipv6" = 1;      | disable IPv6 in IO config                   |
Additional disabled kernel modules:
```
boot.blacklistedKernelModules = [
	"brcmfmac" "brcmutil" "btusb" "snd_bcm2835" "pcspkr"
];
```
Disables: WiFi, BT, Audio, SD Cards, CD-Rom
==Note: this are only kernel modules that can be re-enabled, to properly disabled hardware components refer to hardware devices tree.==

##### Machine Identity
```
HostName = pi-server
TimeZone = Europe/Kyiv
```
#### Storage
RPI5 Uses HAT extension plate with two NVME M2 drive slots populated with 

| Drive name | Part Name | FS type | Label    | Size(GB) | Role              | Model        | Link                                                                    |
| ---------- | --------- | ------- | -------- | -------- | ----------------- | ------------ | ----------------------------------------------------------------------- |
| nvme0n1    | nvme0n1p1 | vfat    | FIRMWARE | 1        | bootloader        | Patriot P300 | [link](https://hard.rozetka.com.ua/ua/patriot_p300p128gm28/p265346706/) |
| nvme0n1    | nvme0n1p2 | ext4    | NIXIS_SD | 119      | root              | Patriot P300 | [link](https://hard.rozetka.com.ua/ua/patriot_p300p128gm28/p265346706/) |
| nvme1n1    | nvme1n1p1 | ext4    | NAS      | 931      | samba share drive | Kingston NV2 | [link](https://hard.rozetka.com.ua/ua/kingston-snv2s-1000g/p353568015/) |
The intention is again to separate root partition hosting services from samba storage module improving overall performance. 

#### Users 
Users are defines as Mutable=false with a main user kane. 
member of groups: wheel and Tailscale
User password is hashed and saved in secrets.nix
Also has ssh Auth key set up and saved in secrets.nix
```
users.users.${mainUser} = {
	isNormalUser = true;
	description = "Main User";
	extraGroups = [ "wheel" "tailscale" ];
	initialHashedPassword = secrets.mainUserHashedPassword;
	openssh.authorizedKeys.keys = [ secrets.mainUserSshPublicKey ];
};
```
#### Networking and Firewall 
The system is defined from the start and does not require additional network configuration from DHCP thus it is disabled. 
The IP is defined: 192.168.0.228 and is pinned to MAC on router side. 
Default gateway: 192.168.0.1
Nameservers: 127.0.0.1, 1.1.1.1 - localhost pointing to unbound and cloudflare as a fallback option
```
networking.useDHCP = false;
networking.interfaces.end0.ipv4.addresses = [
	{ address = serverStaticIP; prefixLength = 24; }
];
networking.defaultGateway = defaultGatewayIP;
networking.nameservers = [ "127.0.0.1" "1.1.1.1" ];

```
##### Firewall
Is enabled by default and defines that only local network machines can connect as well Tailscale network users.  
This is achieved in two different ways, since Tailscale is a service which creates it's own interface it is trusted but this cannot be done with Ethernet because all traffic from it will be unrestricted by default, thus specific address range is allowed.  
Additionally, specific ports should be enabled to allow the access from outside, such as:

| TCP | UDP   | Description | Comment                                    |
| --- | ----- | ----------- | ------------------------------------------ |
|     | 41641 | Tailscale   | Required for Tailscale external connection |
==Note: Ping option is added for debugging purposes and should not be enabled unless necessary.== 
```
networking.firewall = {
	enable = true;
	allowPing = true;
	checkReversePath = "loose";
	trustedInterfaces = [ "lo" config.services.tailscale.interfaceName ];
	# Allow unrestricted access only from local network sometimes need additional port specification
	extraInputRules = ''
		ip saddr ${localNetworkCIDR} accept
	allowedTCPPorts = [ ];
	allowedUDPPorts = [ 41641 ];
	'';
};
```
#### Services
Designed to house multiple services for personal use, unfortunately not all of them are as Nix compliant as I want it to be so there is a room for improvement and compromise. 
Ideally it is planned to separate services on one-per-file basis to keep configuration clean and consistent. 

##### Open SSH
Allows external SSH connection from local network and Tailscale.
Is accessible only with Key Auth.
```
# OpenSSH Service
services.openssh = {
	enable = true;
	# Enforce key-only login
	# rpi5-flake allows password auth by default
	settings.PasswordAuthentication = false;
};
```
##### Tailscale
External VPN service native to Nix that allows users to connect to machines in network. 
In this specific configuration the PRI5 advertises thole local network to Tailscale thus acting as hub-connection controller for VPN service. 
To allow access to this network download Tailscale account and log in as user on it, also requires invite to Tailscale network from admin as well as approval in console. 
```
services.tailscale = {
	# temporary disabled for firt boot
	enable = true;
	# enable local network advertisment for tailnetwork
	# allows access to local network for devices on tailnetwork throu pi
	extraUpFlags = [
	  "--advertise-routes=${localNetworkCIDR}"
	];
  };
```
##### Caddy
Reverse proxy service mainly used to apply domain names to machines in network.
```
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
```
##### Unbound
Recursive DNS resolver, eliminates the necessity to contact ISP. Also, defines local zone and local names.
```
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

```
##### Blocky
Network ADBlocker, used as a replacement to PiHole due to it being in unstable state right now. 
Controls what can be seen and loaded on local network as well as filters majority of ads. 
```
services.blocky = {
	enable = true;
	settings = {
	  # listen to all interfaces
	  ports.dns = 53;
	  # use unbound as only default dns resolver
	  upstreams.groups.default = [ "127.0.0.1:5335" ];
	  # fallback dns
	  bootstrapDns = [ "1.1.1.1" "1.1.1.2" ];
	  # blocking config 
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
```
##### Samba
File sharing service defines nvme1n1 as a whole shared drive accessible from the local network only for specific user kane. 
Contains some performance improvements and is expected to be ideal solution for local network. 
But has some downsides, it was noticed that connection may vary and be unstable if several operations are taking place on the shared drive. 
Thus the alternative may be evaluated some time later. 
```
services.samba = {
	    # temporary disabled for firt boot
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
```
##### Updater
Simple self-update service whole purpose of which is to update and rebuild the system on monthly basis, reducing the need for manual intervention.
Defined as systemd service.
```
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
```
