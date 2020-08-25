{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.crm;
in {
  options.services.crm = {
    enable = mkOption {
      description = "Whether to enable CRM services";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;

    docker-containers.monica = {
      image = "monicahq/monicahq";
      environment = {
        APP_KEY = "ZmzrCkecdc6bK1KXpCV36uB0eRmn03AL";
        DB_HOST = "mysql";
      };
      extraDockerOptions = [ "--network=nextcloud" ];
      ports = [ "8070:80" ];
      volumes = [ "/var/lib/monica:/var/www/monica/storage" ];
    };

    docker-containers.mysql = {
      image = "mysql:5.7";
      environment = {
        MYSQL_RANDOM_ROOT_PASSWORD = "true";
        MYSQL_DATABASE = "monica";
        MYSQL_USER = "mysql";
        MYSQL_PASSWORD = "mysql";
      };
      extraDockerOptions = [ "--network=monica" ];
      volumes = [ "/var/lib/mysql:/var/lib/mysql" ];
    };
  };
}
