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
    # ipv4
    useDHCP = true;

    # ipv6
    enableIPv6 = true;
    interfaces.enp1s0 = {
      ipv6.addresses = [
        {
          address = "2a01:4f8:c010:a83e::";
          prefixLength = 64;
        }
      ];
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp1s0";
    };

    # firewall
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
  services.fail2ban = {
    enable = true;
    maxretry = 3; # Ban IP after 3 failures
    bantime = "24h"; # Ban IPs for one day on the first ban
  };

  ## USERS
  users.mutableUsers = false;

  # - root -
  users.users.root.hashedPasswordFile = "/root/hashedPassword";

  # - deploy (homepage) -
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

  # - behrn -
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

  system.stateVersion = "24.11";
}
