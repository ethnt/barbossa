{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./components/htpc.nix
    ./components/tig.nix
    ./components/elk.nix
    ./components/web.nix
    ./components/time-machine.nix
    ./components/apartment.nix
    ./components/satan.nix
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

  networking = {
    hostName = "barbossa";
    useDHCP = false;

    interfaces.eno1.useDHCP = true;
    interfaces.wlp0s20f3.useDHCP = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 161 443 548 5601 8123 ];
      allowedUDPPorts = [ 22 80 161 443 548 5601 8123 9993 ];
      allowedUDPPortRanges = [{
        from = 60000;
        to = 61000;
      }];
    };
  };

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
    apacheHttpd
    bat
    fd
    filebeat
    fzf
    git
    htop
    lm_sensors
    mosh
    net-snmp
    nodejs-12_x
    python3
    ripgrep
    vim_configurable
    wget
  ];

  programs.fish.enable = true;

  services.openssh.enable = true;

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

  services.elk = {
    enable = true;
    systemdUnits = [
      "elasticsearch.service"
      "grafana.service"
      "influxdb.service"
      "logstash.service"
      "netatalk.service"
      "nginx.service"
      "nzbget.service"
      "plex.service"
      "radarr.service"
      "sonarr.service"
      "telegraf.service"
    ];
  };

  services.web = {
    enable = true;
    group = "users";
    user = "barbossa";
    contactEmail = "ethan.turkeltaub+barbossa@hey.com";
  };

  services.timeMachine = {
    enable = true;
    user = "ethan";
    capsuleName = "TARDIS";
    backupDirectory = "/mnt/omnibus/time-machine";
    sizeLimit = "4000000";
  };

  services.apartment = { enable = true; };

  services.satan = { enable = true; };

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
