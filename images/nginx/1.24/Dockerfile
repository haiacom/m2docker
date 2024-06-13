FROM nginx:1.24

MAINTAINER Hai Le <minhhaislvl@gmail.com>

ENV UPLOAD_MAX_FILESIZE 64M
ENV FPM72_HOST fpm72
ENV FPM74_HOST fpm74
ENV FPM72_PORT 9002
ENV FPM74_PORT 9004
ENV UPSTREAM_HOST web
ENV UPSTREAM_PORT 8080
ENV SSL_KEY m2local.key
ENV SSL_CERT m2local.crt
ENV MAGENTO_ROOT /var/www
ENV MAGENTO_RUN_MODE developer
ENV MFTF_UTILS 0
ENV DEBUG true
ENV NGINX_WORKER_PROCESSES 1
ENV NGINX_WORKER_CONNECTIONS 1024
ENV NVM_DIR /root/.nvm
ENV NODE_VERSION 18.16.0

COPY etc/nginx.conf /etc/nginx/
COPY etc/vhost-default.conf /etc/nginx/conf.d/vhost-default.conf

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN mkdir /etc/nginx/ssl

RUN apt-get update && \
    apt-get install -y openssl

# install npm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash \
    && source $NVM_DIR/nvm.sh \
    && /bin/bash $NVM_DIR/nvm.sh \
    && source $HOME/.bashrc \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default \
    && npm install -g yarn
RUN openssl req -x509 -newkey rsa:2048 -sha256 -days 730 -nodes \
  -keyout /etc/nginx/ssl/${SSL_KEY} -out /etc/nginx/ssl/${SSL_CERT} \
  -subj "/C=US/ST=TX/L=Austin/O=Magento Commerce/OU=Magento Docker/CN=*.local" \
  -addext "subjectAltName=DNS:*.local,DNS:www.*.local"

VOLUME ${MAGENTO_ROOT}

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN ["chmod", "+x", "/docker-entrypoint.sh"]
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 443

WORKDIR ${MAGENTO_ROOT}

CMD ["nginx", "-g", "daemon off;"]
