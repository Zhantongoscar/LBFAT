FROM emqx/emqx:latest

COPY emqx.conf /opt/emqx/etc/emqx.conf

EXPOSE 1883 8083 8084 8883 18083

CMD ["/opt/emqx/bin/emqx", "foreground"] 