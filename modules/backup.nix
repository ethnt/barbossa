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
    environment.systemPackages = with pkgs; [ restic ];

    services.restic.backups = {
      configuration = {
        paths = [ "/etc/nixos" "/var/lib" "/home" ];
        repository = "s3:s3.amazonaws.com/barbossa-configuration-backup";
        passwordFile = "/etc/secrets/restic/password";
        s3CredentialsFile = "/etc/secrets/restic/s3";
        initialize = true;
        timerConfig = {
          OnCalendar = "03:00";
          RandomizedDelaySec = "3h";
        };
      };
    };
  };
}
