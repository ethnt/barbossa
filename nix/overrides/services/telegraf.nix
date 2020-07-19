# This is a modified version of the Telegraf service that allows configuration of the user and lines for extraConfig.

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.telegraf;

  configFile = pkgs.writeText "config.toml" cfg.extraConfig;
in {
  options = {
    services.telegraf = {
      enable = mkEnableOption "telegraf server";

      package = mkOption {
        default = pkgs.telegraf;
        defaultText = "pkgs.telegraf";
        description = "Which telegraf derivation to use";
        type = types.package;
      };

      extraConfig = mkOption {
        default = "";
        description = "Extra configuration options for telegraf";
        type = types.lines;
        example = ''
          [[inputs.snmp]]
        '';
      };

      user = mkOption {
        default = "telegraf";
        description = "Which user to run telegraf as";
        type = types.str;
      };
    };
  };

  config = mkIf config.services.telegraf.enable {
    systemd.services.telegraf = {
      description = "Telegraf Agent";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      path = [ "/run/current-system/sw" ];
      serviceConfig = {
        ExecStart = ''${cfg.package}/bin/telegraf -config "${configFile}"'';
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        User = cfg.user;
        Restart = "on-failure";
      };
    };
  };
}
