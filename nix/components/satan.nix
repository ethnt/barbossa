{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.satan;
in {
  options.services.satan = {
    enable = mkOption {
      description = "Whether to enable network services";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ tailscale ];

    services.zerotierone = {
      enable = true;
      joinNetworks = [ "e4da7455b2239e18" ];
      port = 9993;
    };
  };
}
