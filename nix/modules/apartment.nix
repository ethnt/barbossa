{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.apartment;
in {
  options.services.apartment = {
    enable = mkOption {
      description = "Whether to enable apartment services";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;

    docker-containers.hass = {
      image = "homeassistant/home-assistant:latest";
      environment = { TZ = "America/New_York"; };
      extraDockerOptions = [ "--net=host" ];
      volumes = [ "/var/lib/hass:/config" ];
    };
  };
}
