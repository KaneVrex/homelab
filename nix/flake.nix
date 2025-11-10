{
  description = "NixOS configuration for the RPi 5 server using raspberry-pi-nix";

  inputs = {

    # Nixpkgs for a stable release 25.05
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Use the  maintained nvmd flake for rpi5 build    
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
  };

  outputs = { self, nixpkgs, nixos-raspberrypi, ... }@inputs: let
    
    # Define target architecture: rpi5
    system = "aarch64-linux"; 

  in{
    # Define the NixOS systems
    nixosConfigurations = {

      # pi-server - is the hostname
      pi_server = nixos-raspberrypi.lib.nixosSystem {
      
        # inherit system aarch
        inherit system;
      
        # Recognizes build arguments
        specialArgs = { inherit inputs nixos-raspberrypi; };

        modules = [
          # Import the rpi5 modules from the flake
          nixos-raspberrypi.nixosModules.raspberry-pi-5.base
          nixos-raspberrypi.nixosModules.sd-image
          
          # Import configuration file
          ./configuration.nix
        ];
      };
    };

    # build USB installer
    packages.aarch64-linux.sdImage = self.nixosConfigurations.pi_server.config.system.build.sdImage;   
  };
    # cachix to speed up kernel compilation
    # may contain pre-built kernels from raspberry-pi-nix
    nixConfig = {
      extra-substituters = [ 
        "https://nixos-raspberrypi.cachix.org"
        "https://nix-community.cachix.org" 
      ];

      extra-trusted-public-keys = [ 
        "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
        "nix-community.cachix.org-1:2pQvXrfS0xYvLiS5Qn9XpnyYlSU+QfK3A0/BfzU2/8Y="
      ];
    };
}