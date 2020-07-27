{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.elk;
  unstable = import <nixos-unstable> { config = { }; };
  fromUnit = unit: ''
    pipe {
        command => "${pkgs.systemd}/bin/journalctl -fu ${unit} -o json"
        tags => "${unit}"
        type => "syslog"
        codec => json {}
    }
  '';
in {
  disabledModules = [ "services/search/kibana.nix" ];

  imports = [ <nixos-unstable/nixos/modules/services/search/kibana.nix> ];

  options.services.elk = {
    enable = mkOption {
      description = "Whether to enable the ELK stack";
      type = types.bool;
      default = false;
    };

    systemdUnits = mkOption {
      description = "The systemd units to send to our ELK stack.";
      default = [ ];
      type = types.listOf types.str;
    };

    additionalInputConfig = mkOption {
      description = "Additional logstash input configurations.";
      default = "";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    services.logstash = {
      enable = true;
      plugins = [ pkgs.logstash-contrib ];
      inputConfig = (concatMapStrings fromUnit cfg.systemdUnits)
        + cfg.additionalInputConfig;
      filterConfig = ''
        if [type] == "syslog" {
            # Keep only relevant systemd fields
            # http://www.freedesktop.org/software/systemd/man/systemd.journal-fields.html
            prune {
                whitelist_names => [
                    "type", "@timestamp", "@version",
                    "MESSAGE", "PRIORITY", "SYSLOG_FACILITY", "_SYSTEMD_UNIT"
                ]
            }
            mutate {
                rename => { "_SYSTEMD_UNIT" => "unit" }
            }
        }
      '';
      outputConfig = ''
        elasticsearch {
            hosts => [ "127.0.0.1:9200" ]
        }
      '';
    };

    services.elasticsearch = {
      enable = true;
      package = pkgs.elasticsearch7;
    };

    services.kibana = {
      enable = true;
      listenAddress = "0.0.0.0";
      extraConf = {
        xpack.infra.sources.default.fields.message = [ "MESSAGE" ];
      };
      package = pkgs.kibana7;
    };
  };
}
