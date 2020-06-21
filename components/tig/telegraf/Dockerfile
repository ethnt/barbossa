FROM telegraf:latest

USER root

ADD telegraf.template.conf /etc/telegraf/telegraf.conf

COPY sensors.d/* /etc/sensors.d/

COPY mibs/* /usr/share/snmp/mibs/

RUN echo "deb http://ftp.us.debian.org/debian stretch main non-free" >> /etc/apt/sources.list

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends iputils-ping snmp procps snmp-mibs-downloader && \
  rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get -y install build-essential hddtemp lm-sensors

ADD entrypoint.sh /entrypoint.sh

RUN chmod +x /*.sh

CMD ["/entrypoint.sh"]
