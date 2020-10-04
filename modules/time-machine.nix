{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.timeMachine;
in {
  options.services.timeMachine = {
    enable = mkOption {
      description = "Whether to enable Time Machine Capsule";
      type = types.bool;
      default = false;
    };

    backupDirectory = mkOption {
      description =
        "What directory to back up to (must be string for netatalk configuration)";
      type = types.str;
      default = "/var/backup";
    };

    capsuleName = mkOption {
      description = "Name of the Time Machine Capsule";
      type = types.str;
      default = "Time Machine";
    };

    user = mkOption {
      description = "User to run as for Time Machine";
      type = types.str;
      default = "user";
    };

    sizeLimit = mkOption {
      description = "Size limit for Time Machine backups (in megabytes)";
      type = types.str;
      default = "1000000";
    };
  };

  config = mkIf cfg.enable {
    services.netatalk = {
      enable = true;
      volumes = {
        "${cfg.capsuleName}" = {
          "time machine" = "yes";
          path = cfg.backupDirectory;
          "valid users" = "${cfg.user}";
          "vol size limit" = "${cfg.sizeLimit}";
        };
      };
    };

    services.avahi = {
      enable = true;
      nssmdns = true;

      publish = {
        enable = true;
        userServices = true;
      };
    };

    networking.firewall.allowedTCPPorts = [ 548 636 ];
  };
}
