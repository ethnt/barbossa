# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let
  baseConfig = { allowUnfree = true; };
  unstable = import <nixos-unstable> { config = baseConfig; };
in {
  imports = [
    ./hardware-configuration.nix
    ./overrides/services/telegraf.nix
    ./components/htpc.nix
    <nixos-unstable/nixos/modules/services/misc/radarr.nix>
  ];

  disabledModules =
    [ "services/misc/radarr.nix" "services/monitoring/telegraf.nix" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/sda2";
      preLVM = true;
    };
  };

  networking.hostName = "barbossa";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Run garbage collection every night
  nix.gc = {
    automatic = true;
    dates = "03:15";
  };

  # Mount NAS volumes
  fileSystems."/mnt/omnibus" = {
    device = "omnibus:/volume1/barbossa";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
    ]; # Don't mount until it's first accessed
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    vim_configurable
    htop
    fzf
    fd
    mosh
    apacheHttpd
    python3
    ripgrep
    lm_sensors
    net-snmp
    nodejs-12_x
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  # Allow "unfree" services
  # nixpkgs.config = {
  #   allowUnfree = true;
  # };
  nixpkgs.config = baseConfig // {
    packageOverrides = pkgs: { radarr = unstable.radarr; };
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 22 80 443 8080 7878 8989 32400 ];
  # networking.firewall.allowedUDPPorts = [ 22 80 443 8080 7878 8989 32400 ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # ACME configuration
  security.acme.acceptTerms = true;
  security.acme.email = "ethan.turkeltaub+barbossa@hey.com";

  # Enable Nginx
  services.nginx = {
    enable = true;

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

  services.htpc = {
    enable = true;
    group = "users";
    user = "barbossa";
  };

  # # Enable Plex
  # services.plex = {
  #   enable = true;
  #   openFirewall = true;
  #   group = "users";
  #   user = "barbossa";
  # };

  # # Enable NZBget
  # services.nzbget = {
  #   enable = true;
  #   group = "users";
  #   user = "barbossa";
  # };

  # # Enable Sonarr
  # services.sonarr = {
  #   enable = true;
  #   openFirewall = true;
  #   group = "users";
  #   user = "barbossa";
  # };

  # # Enable Radarr
  # services.radarr = {
  #   enable = true;
  #   openFirewall = true;
  #   group = "users";
  #   user = "barbossa";
  # };

  # Enable InfluxDB
  services.influxdb = {
    enable = true;
    group = "users";
    user = "barbossa";
  };

  # Enable Telegraf
  services.telegraf = {
    enable = true;
    user = "barbossa";
    extraConfig = ''
      [inputs]

      [inputs.cpu]
      collect_cpu_time = true
      percpu = true
      report_active = true
      totalcpu = true

      [inputs.disk]
      ignore_fs = ["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"]
      mount_points = ["/", "/mnt/omnibus"]

      [inputs.diskio]

      [inputs.kernel]

      [inputs.mem]

      [inputs.net]

      [inputs.nginx]
      urls = ["http://localhost/status"]

      [inputs.processes]

      [inputs.procstat]
      exe = ".*"

      [inputs.sensors]

      [[inputs.snmp]]
        agents = ["router"]
        community = "satan"
        version = 2
        # Measurement name
        name = "snmp.EdgeOS"
        ##
        ## Exclusions
        ##
        # Don't want these columns from UCD-SNMP-MIB::laTable
        fielddrop = [ "laErrorFlag", "laErrMessage" ]
        # Don't want these rows from UCD-DISKIO-MIB::diskIOTable
        [inputs.snmp.tagdrop]
          diskIODevice = [ "loop*", "ram*" ]
        ##
        ## System details
        ##
        #  System name (hostname)
        [[inputs.snmp.field]]
          name = "sysName"
          oid = "SNMPv2-MIB::sysName.0"
          is_tag = true
        #  System vendor OID
        [[inputs.snmp.field]]
          name = "sysObjectID"
          oid = "SNMPv2-MIB::sysObjectID.0"
        #  System description
        [[inputs.snmp.field]]
          name = "sysDescr"
          oid = "SNMPv2-MIB::sysDescr.0"
        #  System contact
        [[inputs.snmp.field]]
          name = "sysContact"
          oid = "SNMPv2-MIB::sysContact.0"
        #  System location
        [[inputs.snmp.field]]
          name = "sysLocation"
          oid = "SNMPv2-MIB::sysLocation.0"
        ##
        ## Host/System Resources
        ##
        #  System uptime
        [[inputs.snmp.field]]
          name = "sysUpTime"
          oid = "HOST-RESOURCES-MIB::hrSystemUptime.0"
        #  Number of user sessions
        [[inputs.snmp.field]]
          name = "hrSystemNumUsers"
          oid = "HOST-RESOURCES-MIB::hrSystemNumUsers.0"
        #  Number of process contexts
        [[inputs.snmp.field]]
          name = "hrSystemProcesses"
          oid = "HOST-RESOURCES-MIB::hrSystemProcesses.0"
        #  Device Listing
        [[inputs.snmp.table]]
          oid = "HOST-RESOURCES-MIB::hrDeviceTable"
          [[inputs.snmp.table.field]]
            oid = "HOST-RESOURCES-MIB::hrDeviceIndex"
            is_tag = true
        ##
        ## Context Switches & Interrupts
        ##
        #  Number of interrupts processed
        [[inputs.snmp.field]]
          name = "ssRawInterrupts"
          oid = "UCD-SNMP-MIB::ssRawInterrupts.0"
        #  Number of context switches
        [[inputs.snmp.field]]
          name = "ssRawContexts"
          oid = "UCD-SNMP-MIB::ssRawContexts.0"
        ##
        ## Host performance metrics
        ##
        #  System Load Average
        [[inputs.snmp.table]]
          oid = "UCD-SNMP-MIB::laTable"
          [[inputs.snmp.table.field]]
            oid = "UCD-SNMP-MIB::laNames"
            is_tag = true
        ##
        ## CPU inventory
        ##
        #  Processor listing
        [[inputs.snmp.table]]
          index_as_tag = true
          oid = "HOST-RESOURCES-MIB::hrProcessorTable"
        ##
        ## CPU utilization
        ##
        #  Number of 'ticks' spent on user-level
        [[inputs.snmp.field]]
          name = "ssCpuRawUser"
          oid = "UCD-SNMP-MIB::ssCpuRawUser.0"
        #  Number of 'ticks' spent on reduced-priority
        [[inputs.snmp.field]]
          name = "ssCpuRawNice"
          oid = "UCD-SNMP-MIB::ssCpuRawNice.0"
        #  Number of 'ticks' spent on system-level
        [[inputs.snmp.field]]
          name = "ssCpuRawSystem"
          oid = "UCD-SNMP-MIB::ssCpuRawSystem.0"
        #  Number of 'ticks' spent idle
        [[inputs.snmp.field]]
          name = "ssCpuRawIdle"
          oid = "UCD-SNMP-MIB::ssCpuRawIdle.0"
        #  Number of 'ticks' spent waiting on I/O
        [[inputs.snmp.field]]
          name = "ssCpuRawWait"
          oid = "UCD-SNMP-MIB::ssCpuRawWait.0"
        #  Number of 'ticks' spent in kernel
        [[inputs.snmp.field]]
          name = "ssCpuRawKernel"
          oid = "UCD-SNMP-MIB::ssCpuRawKernel.0"
        #  Number of 'ticks' spent on hardware interrupts
        [[inputs.snmp.field]]
          name = "ssCpuRawInterrupt"
          oid = "UCD-SNMP-MIB::ssCpuRawInterrupt.0"
        #  Number of 'ticks' spent on software interrupts
        [[inputs.snmp.field]]
          name = "ssCpuRawSoftIRQ"
          oid = "UCD-SNMP-MIB::ssCpuRawSoftIRQ.0"
        ##
        ## System Memory (physical/virtual)
        ##
        #  Size of phsyical memory (RAM)
        [[inputs.snmp.field]]
          name = "hrMemorySize"
          oid = "HOST-RESOURCES-MIB::hrMemorySize.0"
        #  Size of real/phys mem installed
        [[inputs.snmp.field]]
          name = "memTotalReal"
          oid = "UCD-SNMP-MIB::memTotalReal.0"
        #  Size of real/phys mem unused/avail
        [[inputs.snmp.field]]
          name = "memAvailReal"
          oid = "UCD-SNMP-MIB::memAvailReal.0"
        #  Total amount of mem unused/avail
        [[inputs.snmp.field]]
          name = "memTotalFree"
          oid = "UCD-SNMP-MIB::memTotalFree.0"
        #  Size of mem used as shared memory
        [[inputs.snmp.field]]
          name = "memShared"
          oid = "UCD-SNMP-MIB::memShared.0"
        #  Size of mem used for buffers
        [[inputs.snmp.field]]
          name = "memBuffer"
          oid = "UCD-SNMP-MIB::memBuffer.0"
        #  Size of mem used for cache
        [[inputs.snmp.field]]
          name = "memCached"
          oid = "UCD-SNMP-MIB::memCached.0"
        ##
        ## Block (Disk) performance
        ##
        #  System-wide blocks written
        [[inputs.snmp.field]]
          name = "ssIORawSent"
          oid = "UCD-SNMP-MIB::ssIORawSent.0"
        #  Number of blocks read
        [[inputs.snmp.field]]
          name = "ssIORawReceived"
          oid = "UCD-SNMP-MIB::ssIORawReceived.0"
        #  Per-device (disk) performance
        [[inputs.snmp.table]]
          oid = "UCD-DISKIO-MIB::diskIOTable"
          [[inputs.snmp.table.field]]
            oid = "UCD-DISKIO-MIB::diskIODevice"
            is_tag = true
        ##
        ## Disk/Partition/Filesystem inventory & usage
        ##
        #  Storage listing
        [[inputs.snmp.table]]
          oid = "HOST-RESOURCES-MIB::hrStorageTable"
          [[inputs.snmp.table.field]]
            oid = "HOST-RESOURCES-MIB::hrStorageDescr"
            is_tag = true
        ##
        ## Interface metrics
        ##
        #  Per-interface traffic, errors, drops
        [[inputs.snmp.table]]
          oid = "IF-MIB::ifTable"
          [[inputs.snmp.table.field]]
            oid = "IF-MIB::ifName"
            is_tag = true
        #  Per-interface high-capacity (HC) counters
        [[inputs.snmp.table]]
          oid = "IF-MIB::ifXTable"
          [[inputs.snmp.table.field]]
            oid = "IF-MIB::ifName"
            is_tag = true
        ##
        ## IP metrics
        ##
        #  System-wide IP metrics
        [[inputs.snmp.table]]
          index_as_tag = true
          oid = "IP-MIB::ipSystemStatsTable"
        ##
        ## ICMP Metrics
        ##
        #  ICMP statistics
        [[inputs.snmp.table]]
          index_as_tag = true
          oid = "IP-MIB::icmpStatsTable"
        #  ICMP per-type statistics
        [[inputs.snmp.table]]
          index_as_tag = true
          oid = "IP-MIB::icmpMsgStatsTable"
        ##
        ## UDP statistics
        ##
        #  Datagrams delivered to app
        [[inputs.snmp.field]]
          name = "udpInDatagrams"
          oid = "UDP-MIB::udpInDatagrams.0"
        #  Datagrams received with no app
        [[inputs.snmp.field]]
          name = "udpNoPorts"
          oid = "UDP-MIB::udpNoPorts.0"
        #  Datagrams received with error
        [[inputs.snmp.field]]
          name = "udpInErrors"
          oid = "UDP-MIB::udpInErrors.0"
        #  Datagrams sent
        [[inputs.snmp.field]]
          name = "udpOutDatagrams"
          oid = "UDP-MIB::udpOutDatagrams.0"
        ##
        ## TCP statistics
        ##
        #  Number of CLOSED -> SYN-SENT transitions
        [[inputs.snmp.field]]
          name = "tcpActiveOpens"
          oid = "TCP-MIB::tcpActiveOpens.0"
        #  Number of SYN-RCVD -> LISTEN transitions
        [[inputs.snmp.field]]
          name = "tcpPassiveOpens"
          oid = "TCP-MIB::tcpPassiveOpens.0"
        #  Number of SYN-SENT/RCVD -> CLOSED transitions
        [[inputs.snmp.field]]
          name = "tcpAttemptFails"
          oid = "TCP-MIB::tcpAttemptFails.0"
        #  Number of ESTABLISHED/CLOSE-WAIT -> CLOSED transitions
        [[inputs.snmp.field]]
          name = "tcpEstabResets"
          oid = "TCP-MIB::tcpEstabResets.0"
        #  Number of ESTABLISHED or CLOSE-WAIT
        [[inputs.snmp.field]]
          name = "tcpCurrEstab"
          oid = "TCP-MIB::tcpCurrEstab.0"
        #  Number of segments received
        [[inputs.snmp.field]]
          name = "tcpInSegs"
          oid = "TCP-MIB::tcpInSegs.0"
        #  Number of segments sent
        [[inputs.snmp.field]]
          name = "tcpOutSegs"
          oid = "TCP-MIB::tcpOutSegs.0"
        #  Number of segments retransmitted
        [[inputs.snmp.field]]
          name = "tcpRetransSegs"
          oid = "TCP-MIB::tcpRetransSegs.0"
        #  Number of segments received with error
        [[inputs.snmp.field]]
          name = "tcpInErrs"
          oid = "TCP-MIB::tcpInErrs.0"
        #  Number of segments sent w/RST
        [[inputs.snmp.field]]
          name = "tcpOutRsts"
          oid = "TCP-MIB::tcpOutRsts.0"
        ##
        ## IP routing statistics
        ##
        #  Number of valid routing entries
        [[inputs.snmp.field]]
          name = "inetCidrRouteNumber"
          oid = "IP-FORWARD-MIB::inetCidrRouteNumber.0"
        #  Number of valid entries discarded
        [[inputs.snmp.field]]
          name = "inetCidrRouteDiscards"
          oid = "IP-FORWARD-MIB::inetCidrRouteDiscards.0"
        #  Number of valid forwarding entries
        [[inputs.snmp.field]]
          name = "ipForwardNumber"
          oid = "IP-FORWARD-MIB::ipForwardNumber.0"
        ##
        ## IP routing statistics
        ##
        # Number of valid routes discarded
        [[inputs.snmp.field]]
          name = "ipRoutingDiscards"
          oid = "RFC1213-MIB::ipRoutingDiscards.0"
        ##
        ## SNMP metrics
        ##
        #  Number of SNMP messages received
        [[inputs.snmp.field]]
          name = "snmpInPkts"
          oid = "SNMPv2-MIB::snmpInPkts.0"
        #  Number of SNMP Get-Request received
        [[inputs.snmp.field]]
          name = "snmpInGetRequests"
          oid = "SNMPv2-MIB::snmpInGetRequests.0"
        #  Number of SNMP Get-Next received
        [[inputs.snmp.field]]
          name = "snmpInGetNexts"
          oid = "SNMPv2-MIB::snmpInGetNexts.0"
        #  Number of SNMP objects requested
        [[inputs.snmp.field]]
          name = "snmpInTotalReqVars"
          oid = "SNMPv2-MIB::snmpInTotalReqVars.0"
        #  Number of SNMP Get-Response received
        [[inputs.snmp.field]]
          name = "snmpInGetResponses"
          oid = "SNMPv2-MIB::snmpInGetResponses.0"
        #  Number of SNMP messages sent
        [[inputs.snmp.field]]
          name = "snmpOutPkts"
          oid = "SNMPv2-MIB::snmpOutPkts.0"
        #  Number of SNMP Get-Request sent
        [[inputs.snmp.field]]
          name = "snmpOutGetRequests"
          oid = "SNMPv2-MIB::snmpOutGetRequests.0"
        #  Number of SNMP Get-Next sent
        [[inputs.snmp.field]]
          name = "snmpOutGetNexts"
          oid = "SNMPv2-MIB::snmpOutGetNexts.0"
        #  Number of SNMP Get-Response sent
        [[inputs.snmp.field]]
          name = "snmpOutGetResponses"
          oid = "SNMPv2-MIB::snmpOutGetResponses.0"

      [[inputs.snmp]]
        # List of agents to poll
        agents = [ "192.168.1.59", "192.168.1.60", "192.168.1.61", "192.168.1.66" ]
        # Polling interval
        interval = "60s"
        # Timeout for each SNMP query.
        timeout = "10s"
        # Number of retries to attempt within timeout.
        retries = 3
        # SNMP version
        version = 2
        # SNMP community string.
        community = "satan"
        # Measurement name
        name = "snmp.UAP"
        ##
        ## System Details
        ##
        #  System name (hostname)
        [[inputs.snmp.field]]
          is_tag = true
          name = "sysName"
          oid = "RFC1213-MIB::sysName.0"
        #  System vendor OID
        [[inputs.snmp.field]]
          name = "sysObjectID"
          oid = "RFC1213-MIB::sysObjectID.0"
        #  System description
        [[inputs.snmp.field]]
          name = "sysDescr"
          oid = "RFC1213-MIB::sysDescr.0"
        #  System contact
        [[inputs.snmp.field]]
          name = "sysContact"
          oid = "RFC1213-MIB::sysContact.0"
        #  System location
        [[inputs.snmp.field]]
          name = "sysLocation"
          oid = "RFC1213-MIB::sysLocation.0"
        #  System uptime
        [[inputs.snmp.field]]
          name = "sysUpTime"
          oid = "RFC1213-MIB::sysUpTime.0"
        #  UAP model
        [[inputs.snmp.field]]
          name = "unifiApSystemModel"
          oid = "UBNT-UniFi-MIB::unifiApSystemModel.0"
        #  UAP firmware version
        [[inputs.snmp.field]]
          name = "unifiApSystemVersion"
          oid = "UBNT-UniFi-MIB::unifiApSystemVersion.0"
        #  Per-interface traffic, errors, drops
        [[inputs.snmp.table]]
          oid = "IF-MIB::ifTable"
          [[inputs.snmp.table.field]]
            is_tag = true
            oid = "IF-MIB::ifDescr"
        ##
        ## Interface Details & Metrics
        ##
        #  Wireless interfaces
        [[inputs.snmp.table]]
          oid = "UBNT-UniFi-MIB::unifiRadioTable"
          [[inputs.snmp.table.field]]
            is_tag = true
            oid = "UBNT-UniFi-MIB::unifiRadioName"
          [[inputs.snmp.table.field]]
            is_tag = true
            oid = "UBNT-UniFi-MIB::unifiRadioRadio"
        #  BSS instances
        [[inputs.snmp.table]]
          oid = "UBNT-UniFi-MIB::unifiVapTable"
          [[inputs.snmp.table.field]]
            is_tag = true
            oid = "UBNT-UniFi-MIB::unifiVapName"
          [[inputs.snmp.table.field]]
            is_tag = true
            oid = "UBNT-UniFi-MIB::unifiVapRadio"
          [[inputs.snmp.table.field]]
            is_tag = true
            oid = "UBNT-UniFi-MIB::unifiVapEssId"
        #  Ethernet interfaces
        [[inputs.snmp.table]]
          oid = "UBNT-UniFi-MIB::unifiIfTable"
          [[inputs.snmp.table.field]]
            is_tag = true
            oid = "UBNT-UniFi-MIB::unifiIfName"
        ##
        ## SNMP metrics
        ##
        #  Number of SNMP messages received
        [[inputs.snmp.field]]
          name = "snmpInPkts"
          oid = "SNMPv2-MIB::snmpInPkts.0"
        #  Number of SNMP Get-Request received
        [[inputs.snmp.field]]
          name = "snmpInGetRequests"
          oid = "SNMPv2-MIB::snmpInGetRequests.0"
        #  Number of SNMP Get-Next received
        [[inputs.snmp.field]]
          name = "snmpInGetNexts"
          oid = "SNMPv2-MIB::snmpInGetNexts.0"
        #  Number of SNMP objects requested
        [[inputs.snmp.field]]
          name = "snmpInTotalReqVars"
          oid = "SNMPv2-MIB::snmpInTotalReqVars.0"
        #  Number of SNMP Get-Response received
        [[inputs.snmp.field]]
          name = "snmpInGetResponses"
          oid = "SNMPv2-MIB::snmpInGetResponses.0"
        #  Number of SNMP messages sent
        [[inputs.snmp.field]]
          name = "snmpOutPkts"
          oid = "SNMPv2-MIB::snmpOutPkts.0"
        #  Number of SNMP Get-Request sent
        [[inputs.snmp.field]]
          name = "snmpOutGetRequests"
          oid = "SNMPv2-MIB::snmpOutGetRequests.0"
        #  Number of SNMP Get-Next sent
        [[inputs.snmp.field]]
          name = "snmpOutGetNexts"
          oid = "SNMPv2-MIB::snmpOutGetNexts.0"
        #  Number of SNMP Get-Response sent
        [[inputs.snmp.field]]
          name = "snmpOutGetResponses"
          oid = "SNMPv2-MIB::snmpOutGetResponses.0"
        #  Processor listing
        [[inputs.snmp.table]]
          index_as_tag = true
          oid = "HOST-RESOURCES-MIB::hrProcessorTable"
        ##
        ## Host performance metrics
        ##
        #  System Load Average
        [[inputs.snmp.table]]
          oid = "UCD-SNMP-MIB::laTable"
          [[inputs.snmp.table.field]]
            oid = "UCD-SNMP-MIB::laNames"
            is_tag = true
        ##
        ## System Memory (physical/virtual)
        ##
        #  Size of swap sapce configured
        [[inputs.snmp.field]]
          name = "memTotalSwap"
          oid = "UCD-SNMP-MIB::memTotalSwap.0"
        #  Size of swap sapce unused/avail
        [[inputs.snmp.field]]
          name = "memAvailSwap"
          oid = "UCD-SNMP-MIB::memAvailSwap.0"
        #  Size of real/phys mem installed
        [[inputs.snmp.field]]
          name = "memTotalReal"
          oid = "UCD-SNMP-MIB::memTotalReal.0"
        #  Size of real/phys mem unused/avail
        [[inputs.snmp.field]]
          name = "memAvailReal"
          oid = "UCD-SNMP-MIB::memAvailReal.0"
        #  Total amount of mem unused/avail
        [[inputs.snmp.field]]
          name = "memTotalFree"
          oid = "UCD-SNMP-MIB::memTotalFree.0"
        #  Size of mem used as shared memory
        [[inputs.snmp.field]]
          name = "memShared"
          oid = "UCD-SNMP-MIB::memShared.0"
        #  Size of mem used for buffers
        [[inputs.snmp.field]]
          name = "memBuffer"
          oid = "UCD-SNMP-MIB::memBuffer.0"
        #  Size of mem used for cache
        [[inputs.snmp.field]]
          name = "memCached"
          oid = "UCD-SNMP-MIB::memCached.0"
        #

      [[inputs.snmp]]
        # List of agents to poll
        agents = [  "omnibus" ]
        # Polling interval
        interval = "60s"
        # Timeout for each SNMP query.
        timeout = "10s"
        # Number of retries to attempt within timeout.
        retries = 3
        # SNMP version, UAP only supports v1
        version = 2
        # SNMP community string.
        community = "satan"
        # The GETBULK max-repetitions parameter
        max_repetitions = 30
        # Measurement name
        name = "snmp.SYNO"
        ##
        ## System Details
        ##
        #  System name (hostname)
        [[inputs.snmp.field]]
          is_tag = true
          name = "sysName"
          oid = "RFC1213-MIB::sysName.0"
        #  System vendor OID
        [[inputs.snmp.field]]
          name = "sysObjectID"
          oid = "RFC1213-MIB::sysObjectID.0"
        #  System description
        [[inputs.snmp.field]]
          name = "sysDescr"
          oid = "RFC1213-MIB::sysDescr.0"
        #  System contact
        [[inputs.snmp.field]]
          name = "sysContact"
          oid = "RFC1213-MIB::sysContact.0"
        #  System location
        [[inputs.snmp.field]]
          name = "sysLocation"
          oid = "RFC1213-MIB::sysLocation.0"
        #  System uptime
        [[inputs.snmp.field]]
          name = "sysUpTime"
          oid = "RFC1213-MIB::sysUpTime.0"
        # Inet interface
        [[inputs.snmp.table]]
          oid = "IF-MIB::ifTable"
          [[inputs.snmp.table.field]]
            is_tag = true
          oid = "IF-MIB::ifDescr"
        #Syno disk
        [[inputs.snmp.table]]
          oid = "SYNOLOGY-DISK-MIB::diskTable"
          [[inputs.snmp.table.field]]
            is_tag = true
          oid = "SYNOLOGY-DISK-MIB::diskID"
        #Syno raid
        [[inputs.snmp.table]]
          oid = "SYNOLOGY-RAID-MIB::raidTable"
          [[inputs.snmp.table.field]]
            is_tag = true
          oid = "SYNOLOGY-RAID-MIB::raidName"
        #Syno load
        [[inputs.snmp.table]]
          oid = "UCD-SNMP-MIB::laTable"
          [[inputs.snmp.table.field]]
            is_tag = true
          oid = "UCD-SNMP-MIB::laNames"
        #  System memTotalSwap
        [[inputs.snmp.field]]
          name = "memTotalSwap"
          oid = "UCD-SNMP-MIB::memTotalSwap.0"
        #  System memAvailSwap
        [[inputs.snmp.field]]
          name = "memAvailSwap"
          oid = "UCD-SNMP-MIB::memAvailSwap.0"
        #  System memTotalReal
        [[inputs.snmp.field]]
          name = "memTotalReal"
          oid = "UCD-SNMP-MIB::memTotalReal.0"
        #  System memAvailReal
        [[inputs.snmp.field]]
          name = "memAvailReal"
          oid = "UCD-SNMP-MIB::memAvailReal.0"
        #  System memTotalFree
        [[inputs.snmp.field]]
          name = "memTotalFree"
          oid = "UCD-SNMP-MIB::memTotalFree.0"
        #  System Status
        [[inputs.snmp.field]]
          name = "systemStatus"
          oid = "SYNOLOGY-SYSTEM-MIB::systemStatus.0"
        #  System temperature
        [[inputs.snmp.field]]
          name = "temperature"
          oid = "SYNOLOGY-SYSTEM-MIB::temperature.0"
        #  System powerStatus
        [[inputs.snmp.field]]
          name = "powerStatus"
          oid = "SYNOLOGY-SYSTEM-MIB::powerStatus.0"
        #  System systemFanStatus
        [[inputs.snmp.field]]
          name = "systemFanStatus"
          oid = "SYNOLOGY-SYSTEM-MIB::systemFanStatus.0"
        #  System cpuFanStatus
        [[inputs.snmp.field]]
          name = "cpuFanStatus"
          oid = "SYNOLOGY-SYSTEM-MIB::cpuFanStatus.0"
        #  System modelName
        [[inputs.snmp.field]]
          name = "modelName"
          oid = "SYNOLOGY-SYSTEM-MIB::modelName.0"
        #  System serialNumber
        [[inputs.snmp.field]]
          name = "serialNumber"
          oid = "SYNOLOGY-SYSTEM-MIB::serialNumber.0"
        #  System version
        [[inputs.snmp.field]]
          name = "version"
          oid = "SYNOLOGY-SYSTEM-MIB::version.0"
        #  System upgradeAvailable
        [[inputs.snmp.field]]
          name = "upgradeAvailable"
          oid = "SYNOLOGY-SYSTEM-MIB::upgradeAvailable.0"
        # System volume
        [[inputs.snmp.table]]
          oid = "HOST-RESOURCES-MIB::hrStorageTable"
        [[inputs.snmp.table.field]]
            is_tag = true
          oid = "HOST-RESOURCES-MIB::hrStorageDescr"
        # System ssCpuUser
        [[inputs.snmp.field]]
          name = "ssCpuUser"
          oid = ".1.3.6.1.4.1.2021.11.9.0"
        # System ssCpuSystem
        [[inputs.snmp.field]]
          name = "ssCpuSystem"
          oid = ".1.3.6.1.4.1.2021.11.10.0"
        # System ssCpuIdle
        [[inputs.snmp.field]]
          name = "ssCpuIdle"
          oid = ".1.3.6.1.4.1.2021.11.11.0"
        # Service users CIFS
        [[inputs.snmp.table.field]]
          name = "usersCIFS"
          oid = "SYNOLOGY-SERVICES-MIB::serviceUsers"
          oid_index_suffix = "1"
        # Service users AFP
        [[inputs.snmp.table.field]]
          name = "usersAFP"
          oid = "SYNOLOGY-SERVICES-MIB::serviceUsers"
          oid_index_suffix = "2"
        # Service users NFS
        [[inputs.snmp.table.field]]
          name = "usersNFS"
          oid = "SYNOLOGY-SERVICES-MIB::serviceUsers"
          oid_index_suffix = "3"
        # Service users FTP
        [[inputs.snmp.table.field]]
          name = "usersFTP"
          oid = "SYNOLOGY-SERVICES-MIB::serviceUsers"
          oid_index_suffix = "4"
        # Service users SFTP
        [[inputs.snmp.table.field]]
          name = "usersSFTP"
          oid = "SYNOLOGY-SERVICES-MIB::serviceUsers"
          oid_index_suffix = "5"
        # Service users HTTP
        [[inputs.snmp.table.field]]
          name = "usersHTTP"
          oid = "SYNOLOGY-SERVICES-MIB::serviceUsers"
          oid_index_suffix = "6"
        # Service users TELNET
        [[inputs.snmp.table.field]]
          name = "usersTELNET"
          oid = "SYNOLOGY-SERVICES-MIB::serviceUsers"
          oid_index_suffix = "7"
        # Service users SSH
        [[inputs.snmp.table.field]]
          name = "usersSSH"
          oid = "SYNOLOGY-SERVICES-MIB::serviceUsers"
          oid_index_suffix = "8"
        # Service users OTHER
        [[inputs.snmp.table.field]]
          name = "usersOTHER"
          oid = "SYNOLOGY-SERVICES-MIB::serviceUsers"
          oid_index_suffix = "9"
        # UPS Status
        [[inputs.snmp.table.field]]
          name = "upsStatus"
          oid = "SYNOLOGY-UPS-MIB::upsInfoStatus"
        # UPS Load
        [[inputs.snmp.table.field]]
          name = "upsLoad"
          oid = "SYNOLOGY-UPS-MIB::upsInfoLoadValue"
        # UPS Battery Charge
        [[inputs.snmp.table.field]]
          name = "upsCharge"
          oid = "SYNOLOGY-UPS-MIB::upsBatteryChargeValue"
        # UPS Battery Charge Warning
        [[inputs.snmp.table.field]]
          name = "upsWarning"
          oid = "SYNOLOGY-UPS-MIB::upsBatteryChargeWarning"
        # Disks statistics
        [[inputs.snmp.table]]
          oid = "SYNOLOGY-STORAGEIO-MIB::storageIOTable"
          [[inputs.snmp.table.field]]
            is_tag = true
          oid = "SYNOLOGY-STORAGEIO-MIB::storageIODevice"

      [inputs.swap]

      [inputs.system]

      [inputs.systemd_units]

      [outputs]

      [outputs.influxdb]
      database = "telegraf"
      urls = ["http://localhost:8086"]
    '';
    # extraConfig = {
    #   inputs = {
    #     cpu = {
    #       percpu = true;
    #       totalcpu = true;
    #       collect_cpu_time = true;
    #       report_active = true;
    #     };
    #     disk = {
    #       mount_points = [ "/" "/mnt/omnibus" ];
    #       ignore_fs = [
    #         "tmpfs"
    #         "devtmpfs"
    #         "devfs"
    #         "iso9660"
    #         "overlay"
    #         "aufs"
    #         "squashfs"
    #       ];
    #     };
    #     diskio = { };
    #     kernel = { };
    #     mem = { };
    #     net = { };
    #     nginx = { };
    #     processes = { };
    #     sensors = { };
    #     swap = { };
    #     system = { };
    #     procstat = { exe = ".*"; };
    #     systemd_units = { };
    #     snmp = {
    #       agents = [ "udp://router:161" ];
    #       community = "satan";
    #       version = 2;
    #     };
    #   };
    #   outputs = {
    #     influxdb = {
    #       database = "telegraf";
    #       urls = [ "http://localhost:8086" ];
    #     };
    #   };
    # };
  };

  # Enable Grafana
  services.grafana = {
    enable = true;
    addr = "";
    domain = "barbossa";
    port = 3000;
    protocol = "http";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };

  users.extraUsers.barbossa = {
    createHome = true;
    extraGroups = [ "wheel" ];
    group = "users";
    isNormalUser = true;
    uid = 1000;
  };

  users.extraUsers.ethan = {
    createHome = true;
    extraGroups = [ "wheel" ];
    group = "users";
    isNormalUser = true;
    uid = 1001;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}
