{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.backup;
in {
  options.services.backup = {
    enable = mkOption {
      description = "Whether to enable backup services";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    services.duplicati = {
      enable = true;
      interface = "*";
      user = "ethan";
    };
  };
}
