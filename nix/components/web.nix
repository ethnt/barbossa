{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.web;
in {
  options.services.web = {
    enable = mkOption {
      description = "Whether to enable the web stack";
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

    contactEmail = mkOption {
      description = "The email for ACME security";
      type = types.str;
      default = "user@example.org";
    };
  };

  config = mkIf cfg.enable {
    security.acme.acceptTerms = true;
    security.acme.email = cfg.contactEmail;

    services.nginx = {
      enable = true;
      group = cfg.group;
      user = cfg.user;

      virtualHosts."e10.land" = {
        addSSL = true;
        enableACME = true;
        root = "/var/www/e10.land";

        locations."/" = {
          extraConfig = ''
            autoindex on;
          '';
        };
      };

      virtualHosts."barbossa.dev" = {
        addSSL = true;
        enableACME = true;
        root = "/var/www/barbossa.dev";

        locations."/status" = {
          extraConfig = ''
            stub_status;
          '';
        };
      };

      virtualHosts."files.barbossa.dev" = {
        addSSL = true;
        enableACME = true;
        root = "/var/www/barbossa.dev/files";

        locations."/" = {
          extraConfig = ''
            autoindex on;
          '';
        };
      };

      virtualHosts."grafana.barbossa.dev" = {
        addSSL = true;
        enableACME = true;

        root = "/var/www/barbossa.dev/grafana";

        locations."/" = { proxyPass = "http://localhost:3000"; };
      };

      virtualHosts."kibana.barbossa.dev" = {
        addSSL = true;
        enableACME = true;

        root = "/var/www/barbossa.dev/kibana";

        locations."/" = { proxyPass = "http://localhost:5601"; };
      };

      virtualHosts."nzbget.barbossa.dev" = {
        addSSL = true;
        enableACME = true;

        root = "/var/www/barbossa.dev/nzbget";

        locations."/" = { proxyPass = "http://localhost:6789"; };
      };

      virtualHosts."radarr.barbossa.dev" = {
        addSSL = true;
        enableACME = true;

        root = "/var/www/barbossa.dev/radarr";

        locations."/" = { proxyPass = "http://localhost:7878"; };
      };

      virtualHosts."sonarr.barbossa.dev" = {
        addSSL = true;
        enableACME = true;

        root = "/var/www/barbossa.dev/sonarr";

        locations."/" = { proxyPass = "http://localhost:8989"; };
      };

      virtualHosts."plex.barbossa.dev" = {
        http2 = true;

        addSSL = true;
        enableACME = true;

        root = "/var/www/barbossa.dev/plex";

        extraConfig = ''
          send_timeout 100m;

          ssl_stapling on;
          ssl_stapling_verify on;

          ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
          ssl_prefer_server_ciphers on;

          ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-DES-CBC3-SHA:ECDHE-ECDSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';

          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header Host $server_addr;
          proxy_set_header Referer $server_addr;
          proxy_set_header Origin $server_addr;

          gzip on;
          gzip_vary on;
          gzip_min_length 1000;
          gzip_proxied any;
          gzip_types text/plain text/css text/xml application/xml text/javascript application/x-javascript image/svg+xml;
          gzip_disable "MSIE [1-6]\.";

          client_max_body_size 100M;

          proxy_set_header X-Plex-Client-Identifier $http_x_plex_client_identifier;
          proxy_set_header X-Plex-Device $http_x_plex_device;
          proxy_set_header X-Plex-Device-Name $http_x_plex_device_name;
          proxy_set_header X-Plex-Platform $http_x_plex_platform;
          proxy_set_header X-Plex-Platform-Version $http_x_plex_platform_version;
          proxy_set_header X-Plex-Product $http_x_plex_product;
          proxy_set_header X-Plex-Token $http_x_plex_token;
          proxy_set_header X-Plex-Version $http_x_plex_version;
          proxy_set_header X-Plex-Nocache $http_x_plex_nocache;
          proxy_set_header X-Plex-Provides $http_x_plex_provides;
          proxy_set_header X-Plex-Device-Vendor $http_x_plex_device_vendor;
          proxy_set_header X-Plex-Model $http_x_plex_model;

          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";

          proxy_redirect off;
          proxy_buffering off;
        '';

        locations."/" = { proxyPass = "http://localhost:32400/"; };
      };
    };
  };
}
