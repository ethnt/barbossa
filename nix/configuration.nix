{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./components/htpc.nix
    ./components/tig.nix
    ./components/elk.nix
    ./components/web.nix
    ./components/time-machine.nix
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
    filebeat
  ];

  programs.fish.enable = true;

  services.openssh.enable = true;

  networking.firewall.allowedTCPPorts = [ 22 80 161 443 548 5601 ];
  networking.firewall.allowedUDPPorts = [ 22 80 161 443 548 5601 ];
  networking.firewall.enable = true;

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
      "sonarr.service"
      "radarr.service"
      "nzbget.service"
      "plex.service"
      "nginx.service"
      "telegraf.service"
      "influxdb.service"
      "grafana.service"
      "elasticsearch.service"
      "logstash.service"
      "netatalk.service"
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
