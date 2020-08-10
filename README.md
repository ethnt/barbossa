# Barbossa

Barbossa is my home server that runs:

- HTPC (Plex, Sonarr, Radarr, NZBget)
- TIG (Telegraf, InfluxDB, Grafana)
- ELK (ElasticSearch, Logstash, Kibana)
- Nginx
- Time Machine

It runs on [NixOS](//nixos.org/) and all configuration is written on Nix. Deployment is currently with Ansible because NixOps doesn't support macOS to Linux deploys.

## Usage

A lot of this can probably work for you. The files in `nix/components` are pretty portable and have a lot of configuration options. `nix/configuration.nix` and `nix/hardware-configuration.nix` are more specific to my machine, so you may want to double-check those first.
