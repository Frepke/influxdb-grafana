FROM debian:buster-slim
LABEL maintainer="Frepke"

ENV ARCH amd64

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

## Versions
# https://portal.influxdata.com/downloads/
ENV INFLUXDB_VERSION=1.8.4
# https://grafana.com/grafana/download
ENV GRAFANA_VERSION=7.4.3

# Grafana database type
ENV GF_DATABASE_TYPE=sqlite3

WORKDIR /root

RUN apt-get -y update \
    && apt-get install -y \
    adduser \
    libfontconfig1 \
    wget \
    supervisor \
    nano \
    && mkdir -p /var/log/supervisor \
    # Install InfluxDB
    && wget --no-verbose https://dl.influxdata.com/influxdb/releases/influxdb_${INFLUXDB_VERSION}_${ARCH}.deb \
    && dpkg -i influxdb_${INFLUXDB_VERSION}_${ARCH}.deb \
    && rm influxdb_${INFLUXDB_VERSION}_${ARCH}.deb \
    # Install Grafana
    && wget --no-verbose https://dl.grafana.com/oss/release/grafana_${GRAFANA_VERSION}_${ARCH}.deb \
    && dpkg -i grafana_${GRAFANA_VERSION}_${ARCH}.deb \
    && rm grafana_${GRAFANA_VERSION}_${ARCH}.deb \
    # Cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configure InfluxDB
COPY influxdb/influxdb.conf /etc/influxdb/influxdb.conf

# Configure Grafana
# grafana database
    # type=sqlite3
# enable anonymous access
    # enabled = true
# specify organization name that should be used for unauthenticated users
    # org_name = Freeview
# specify role for unauthenticated users
    # org_role = Viewer
COPY grafana/grafana.ini /etc/grafana/grafana.ini

COPY start.sh /start.sh
RUN ["chmod", "+x", "/start.sh"]
CMD ["/start.sh"]
