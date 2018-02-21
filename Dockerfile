FROM ubuntu:16.04

RUN apt update && apt install -y nginx aptly ca-certificates bzip2 gnupg gpgv

ADD mirror.list /etc/apt/mirror.list

RUN mkdir -p /var/www/mirror.local
RUN mkdir -p /mirrors
# RUN /usr/bin/apt-mirror


ADD mirrors.conf /etc/nginx/sites-available/mirror.local

RUN ln -sf /mirrors/mirror/download.docker.com/linux/ubuntu/ /var/www/mirror.local/ubuntu
RUN sed -i '/^daemon/d' /etc/nginx/nginx.conf
RUN sed -i '/^worker_processes/a daemon off;' /etc/nginx/nginx.conf
RUN rm -f /etc/nginx/sites-enabled/default
RUN ln -sf /etc/nginx/sites-available/mirror.local /etc/nginx/sites-enabled/

EXPOSE 80

### aptly
# RUN gpg --no-default-keyring --keyring trustedkeys.gpg --keyserver keys.gnupg.net --recv-keys 7EA0A9C3F273FCD8
# RUN sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 9E3E53F19C7DE460
# RUN gpg --no-default-keyring --keyring /usr/share/keyrings/ubuntu-archive-keyring.gpg --export | gpg --no-default-keyring --keyring trustedkeys.gpg --import
# add key docker
# RUN apt-key fingerprint 0EBFCD88
RUN gpg --no-default-keyring --keyring trustedkeys.gpg --keyserver keys.gnupg.net --recv-keys 7EA0A9C3F273FCD8
RUN aptly -architectures=amd64 mirror create docker https://download.docker.com/linux/ubuntu xenial stable
RUN aptly mirror update docker

CMD ["service", "nginx", "start"]
