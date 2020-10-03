{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.cloud;
in {
  options.services.cloud = {
    enable = mkOption {
      description = "Whether to enable cloud services";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;

    docker-containers.postgres = {
      image = "postgres:latest";
      environment = {
        POSTGRES_DB = "nextcloud";
        POSTGRES_PASSWORD = "postgres";
      };
      extraDockerOptions = [ "--network=nextcloud" ];
    };

    docker-containers.nextcloud = {
      image = "nextcloud:latest";
      environment = { NEXTCLOUD_TRUSTED_DOMAINS = "cloud.barbossa.dev"; };
      extraDockerOptions = [ "--network=nextcloud" ];
      ports = [ "8090:80" ];
      volumes = [ "/mnt/omnibus/cloud:/var/www/html" ];
    };

    # services.postgresql = {
    #   enable = true;

    #   # ensureDatabases = [ "nextcloud" ];
    #   # ensureUsers = [{
    #   #   name = "nextcloud";
    #   #   ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
    #   # }];
    #   initialScript = pkgs.writeText "backend-initScript" ''
    #     CREATE ROLE nextcloud WITH LOGIN PASSWORD 'nextcloud' CREATEDB;
    #     CREATE DATABASE nextcloud;
    #     GRANT ALL PRIVILEGES ON DATABASE nextcloud TO nextcloud;
    #   '';
    #   authentication = lib.mkForce ''
    #     # Generated file; do not edit!
    #     # TYPE  DATABASE        USER            ADDRESS                 METHOD
    #     local   all             all                                     trust
    #     host    all             all             127.0.0.1/32            trust
    #     host    all             all             ::1/128                 trust
    #   '';
    # };

    # systemd.services."nextcloud-setup" = {
    #   requires = [ "postgresql.service" ];
    #   after = [ "postgresql.service" ];
    # };
  };
}
