{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.htpc;
  unstable = import <nixos-unstable> { config = { }; };
in {
  disabledModules = [ "services/misc/radarr.nix" ];

  imports = [ <nixos-unstable/nixos/modules/services/misc/radarr.nix> ];

  options.services.htpc = {
    enable = mkOption {
      description = "Whether to enable HTPC";
      type = types.bool;
      default = false;
    };

    group = mkOption {
      description = "Which group to run as";
      type = types.str;
      default = "users";
    };

    user = mkOption {
      description = "Which user to run as";
      type = types.str;
      default = "user";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.config = {
      allowUnfree = true;
      packageOverrides = pkgs: { radarr = unstable.radarr; };
    };

    services.plex = {
      enable = true;
      openFirewall = true;
      group = cfg.group;
      user = cfg.user;
    };

    services.nzbget = {
      enable = true;
      group = cfg.group;
      user = cfg.user;
    };

    services.sonarr = {
      enable = true;
      openFirewall = true;
      group = cfg.group;
      user = cfg.user;
    };

    services.radarr = {
      enable = true;
      openFirewall = true;
      group = cfg.group;
      user = cfg.user;
    };

    services.tautulli = {
      enable = true;
      group = cfg.group;
      user = cfg.user;
    };

    services.jackett = {
      enable = true;
      openFirewall = true;
      group = cfg.group;
      user = cfg.user;
    };
  };
}
