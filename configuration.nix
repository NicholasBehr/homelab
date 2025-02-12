{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ./apps/borg.nix
    ./apps/nginx.nix
    ./apps/paperless.nix
  ];

  ## BOOTLOADER
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  ## NETWORKING
  networking = {
    hostName = "homelab";
    enableIPv6 = true;
    useDHCP = false;
    interfaces.enp1s0 = {
      ipv6.addresses = [
        {
          address = "2a01:4f8:c010:a83e::";
          prefixLength = 64;
        }
      ];
      ipv4.addresses = [
        {
          address = "49.12.185.52";
          prefixLength = 32;
        }
      ];
    };
    defaultGateway = {
      address = "172.31.1.1";
      interface = "enp1s0";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp1s0";
    };

    # Quad9
    nameservers = [
      "9.9.9.9"
      "149.112.112.112"
      "2620:fe::fe"
      "2620:fe::9"
    ];

    firewall.enable = true;
    firewall.allowedTCPPorts = [
      80 # nginx http
      443 # nginx https
      3851 # ssh
    ];
  };

  ## SSH
  services.openssh = {
    enable = true;
    ports = [ 3851 ];
    settings = {
      X11Forwarding = false;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  services.fail2ban.enable = true;

  ## CI - HOMEPAGE
  users.groups.www = { };
  users.users.www = {
    isNormalUser = true;
    home = "/var/www";
    group = "www";
    shell = pkgs.dash; # rrsync bash security issue
    openssh.authorizedKeys.keys = [
      # append only key
      ''command="${pkgs.rrsync}/bin/rrsync /var/www/homepage",restrict ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFky8zixRqFyQVNlykhWdt4gp1XMi2DATurTgWpuayu4''
    ];
  };
  system.activationScripts = {
    scriptChrootJail = {
      deps = [ "specialfs" ];
      text = ''
        mkdir -p /var/www/
        mkdir -p /var/www/homepage
        chmod 755 /var/www/
        chmod 755 /var/www/homepage
        chown root:root /var/www/
        chown www:www /var/www/homepage
      '';
    };
  };

  ## BEHRN
  users.users.behrn = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "keys"
    ];
    packages = with pkgs; [ ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIbUF1O0ajT8PFQeUyNsJJLjl5P6ByRKI+JlXR1apimR"
    ];
  };
  security.sudo.extraRules = [
    {
      users = [ "behrn" ];
      commands = [
        {
          # needed for colmena
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # ROOT
  users.users.root.hashedPassword = "$y$j9T$gwUVzCIiyNDk5Ybtjtfep.$yaqYMsIBQMMj/5AS92p3WWkpIAuEdHp6T8YEh5ORjl/";

  system.stateVersion = "24.11";
}
