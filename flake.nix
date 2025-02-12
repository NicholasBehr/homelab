{
  description = "NixOS homelab";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      disko,
      ...
    }:
    {
      nixosConfigurations.homelab = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
        ];
      };
      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
          };
        };

        defaults =
          { pkgs, ... }:
          {
            environment.systemPackages = [
              pkgs.curl
              pkgs.gitMinimal
            ];
          };

        homelab =
          { pkgs, ... }:
          {
            deployment = {
              targetHost = "homelab";
              targetPort = 3851;
              targetUser = "behrn";
              buildOnTarget = true;
              keys = {
                ## BORG
                "borg_passphrase" = {
                  keyCommand = [
                    "op"
                    "read"
                    "op://Personal/homelab-borg/passphrase"
                  ];
                  user = "behrn";
                };
                "borg_ssh" = {
                  keyCommand = [
                    "op"
                    "read"
                    "op://Personal/homelab-borg/private key"
                  ];
                  user = "behrn";
                };
                "known_hosts" = {
                  keyCommand = [
                    "op"
                    "read"
                    "op://Personal/homelab-borg/known_hosts"
                  ];
                  destDir = "/root/.ssh";
                };
                ## PAPERLESS
                "nixos-paperless-secret-key" = {
                  keyCommand = [
                    "op"
                    "read"
                    "op://Personal/homelab-paperless/nixos-paperless-secret-key"
                  ];
                  user = "paperless";
                  group = "paperless";
                  permissions = "0400";
                  destDir = "/var/lib/paperless";
                };
              };
            };
            nixpkgs.system = "x86_64-linux";
            imports = [
              disko.nixosModules.disko
              ./configuration.nix
            ];
            time.timeZone = "Europe/Zurich";
          };
      };
    };
}
