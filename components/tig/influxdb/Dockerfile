FROM influxdb:latest

USER root

ADD influxdb.template.conf /influxdb.template.conf

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
