{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./components/htpc.nix
    ./components/tig.nix
    ./components/web.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/sda2";
      preLVM = true;
    };
  };

  networking.hostName = "barbossa";

  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  time.timeZone = "America/New_York";

  nix.gc = {
    automatic = true;
    dates = "03:15";
  };

  fileSystems."/mnt/omnibus" = {
    device = "omnibus:/volume1/barbossa";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
    ]; # Don't mount until it's first accessed
  };

  environment.systemPackages = with pkgs; [
    wget
    vim_configurable
    htop
    fzf
    fd
    mosh
    apacheHttpd
    python3
    ripgrep
    lm_sensors
    net-snmp
    nodejs-12_x
    git
    bat
  ];

  programs.fish.enable = true;

  services.openssh.enable = true;

  # networking.firewall.allowedTCPPorts = [ 22 80 443 8080 7878 8989 32400 ];
  # networking.firewall.allowedUDPPorts = [ 22 80 443 8080 7878 8989 32400 ];
  networking.firewall.enable = false;

  services.htpc = {
    enable = true;
    group = "users";
    user = "barbossa";
  };

  services.tig = {
    enable = true;
    group = "users";
    user = "barbossa";
  };

  services.web = {
    enable = true;
    group = "users";
    user = "barbossa";
    contactEmail = "ethan.turkeltaub+barbossa@hey.com";
  };

  users.extraUsers.barbossa = {
    createHome = true;
    extraGroups = [ "wheel" ];
    group = "users";
    isNormalUser = true;
    uid = 1000;
  };

  users.extraUsers.ethan = {
    createHome = true;
    extraGroups = [ "wheel" ];
    group = "users";
    isNormalUser = true;
    uid = 1001;
    shell = pkgs.fish;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
