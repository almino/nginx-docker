FROM nginx:1.17

ARG APT_FLAGS="-y --no-install-recommends"
ARG NGINX_ROOT="/usr/share/nginx/html"

# COPY default.conf /etc/nginx/conf.d/default.conf
COPY ip_blacklist.sh /usr/local/bin/ip_blacklist

RUN set -ex \
    # && mkdir -pv /etc/nginx/blacklist/ \
    && mkdir -pv ${NGINX_ROOT} \
    && mkdir -pv /etc/nginx/domains/ \
    && mkdir -pv /etc/nginx/snippets/ \
    && chmod +x /usr/local/bin/ip_blacklist \
    && apt-get update \
    && apt-get ${APT_FLAGS} install curl \
    # https://github.com/nginxinc/docker-nginx/blob/23a990403d6dbe102bf2c72ab2f6a239e940e3c3/mainline/buster/Dockerfile#L87
    && apt-get remove --purge --auto-remove -y \
    # https://www.tecmint.com/useful-basic-commands-of-apt-get-and-apt-cache-for-package-management/
    && apt-get autoclean \
    # https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run
    && rm -rf /var/lib/apt/lists/* \
    && sed -E "s:^([\t ]*)(keepalive_timeout.+):\1#\2:" -i /etc/nginx/nginx.conf \
    && sed '$i\ \ \ \ include domains/*.conf;' -i /etc/nginx/nginx.conf

# COPY blacklist/ /etc/nginx/blacklist/
COPY conf.d/ /etc/nginx/conf.d/
COPY snippets/ /etc/nginx/snippets/

WORKDIR ${NGINX_ROOT}