FROM debian:jessie

LABEL maintainer="Angel Manchev <angel@manchev.pro>"

ENV DEBIAN_FRONTEND noninteractive

# Fixes some weird terminal issues such as broken clear / CTRL+L
ENV TERM=linux

# Install utils
RUN apt-get update --fix-missing
RUN apt-get install -y --no-install-recommends \
    build-essential \
    software-properties-common \
    python-software-properties \
    supervisor \
    htop \ 
    nano \ 
    apt-utils \ 
    git \
    curl \ 
    wget \ 
    ssmtp \ 
    xz-utils \
    locate \ 
    sudo \
    openssh-server \ 
    unzip

# Configure SSHd
RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

# Install nginx
RUN apt-get install -y --no-install-recommends nginx

# Prepare for instaling PHP
RUN apt-get install -y apt-transport-https lsb-release ca-certificates && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list && \
    apt-get update

# Install PHP 7.2
RUN apt-get install -y imagemagick graphicsmagick && \
    apt-get install -y  php7.2-bcmath \ 
                        php7.2-bz2 \
                        php7.2-cli \
                        php7.2-common \
                        php7.2-curl \
                        php7.2-dba \
                        php7.2-fpm \
                        php7.2-gd \
                        php7.2-gmp \
                        php7.2-imap \
                        php7.2-intl \
                        php7.2-ldap \
                        php7.2-mbstring \
                        php7.2-mysql \
                        php7.2-odbc \
                        php7.2-pgsql \
                        php7.2-recode \
                        php7.2-snmp \
                        php7.2-soap \
                        php7.2-tidy \
                        php7.2-xml \
                        php7.2-xmlrpc \
                        php7.2-xsl \
                        php7.2-zip \
                        php7.2-redis \
                        php7.2-sqlite3
# Mcrypt
RUN apt-get install -y php-pear && \
    apt-get install -y php7.2-dev && \
    apt-get install -y gcc make autoconf libc-dev pkg-config && \
    apt-get install -y libmcrypt-dev && \
    pecl install mcrypt-1.0.1 && \
    sudo bash -c "echo extension=/usr/lib/php/20170718/mcrypt.so > /etc/php/7.2/cli/conf.d/mcrypt.ini" && \
    sudo bash -c "echo extension=/usr/lib/php/20170718/mcrypt.so > /etc/php/7.2/fpm/conf.d/mcrypt.ini"

# Install Composer
RUN mkdir /tmp/composer/ && \
    cd /tmp/composer && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    chmod a+x /usr/local/bin/composer && \
    cd / && \
    rm -rf /tmp/composer

# Add one more user to container
RUN useradd dev -g www-data -d /home/dev -p 1 -s /bin/bash && \
    echo 'dev ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    mkdir -p /home/dev && \
    chown dev:www-data /home/dev 

# Additional configurations for fpm
RUN sed -i -e "/listen = .*/c\listen = [::]:9000" /etc/php/7.2/fpm/pool.d/www.conf && \
    sed -i -e 's/^user = www-data$/user = dev/g' /etc/php/7.2/fpm/pool.d/www.conf && \
    sed -i -e 's/^group = www-data$/group = www-data/g' /etc/php/7.2/fpm/pool.d/www.conf && \
    sed -i -e 's/^listen.owner = www-data$/listen.owner = dev/g' /etc/php/7.2/fpm/pool.d/www.conf && \
    sed -i -e 's/^listen.group = www-data$/listen.group = www-data/g' /etc/php/7.2/fpm/pool.d/www.conf && \
    sed -i -e 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php/7.2/fpm/php.ini && \
    sed -i -e 's/upload_max_filesize = 2M/upload_max_filesize = 256M/g' /etc/php/7.2/fpm/php.ini && \
    sed -i -e 's/post_max_size = 8M/post_max_size = 512M/g' /etc/php/7.2/fpm/php.ini && \
    sed -i -e 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/7.2/fpm/php.ini && \
    sed -i -e 's/fastcgi_param  SERVER_PORT        $server_port;/fastcgi_param  SERVER_PORT        $http_x_forwarded_port;/g' /etc/nginx/fastcgi.conf && \
    sed -i -e 's/fastcgi_param  SERVER_PORT        $server_port;/fastcgi_param  SERVER_PORT        $http_x_forwarded_port;/g' /etc/nginx/fastcgi_params && \
    sed -i -e '/sendfile on;/a\        fastcgi_read_timeout 300\;' /etc/nginx/nginx.conf && \
    sed -i -e 's/^user www-data;$/user dev www-data;/g' /etc/nginx/nginx.conf

# Disable xdebug.so extension
RUN echo ';zend_extension=xdebug.so' > /etc/php/7.2/cli/conf.d/20-xdebug.ini

RUN mkdir --mode 777 /var/run/php && \
    chmod -R 777 /var/www/html /var/log && \
    mkdir -p /run /var/lib/nginx /var/lib/php && \
    chmod -R 777 /run /var/lib/nginx /var/lib/php /etc/php/7.2/fpm/php.ini && \
    nginx -t

# This folder is needed for starting SSH service.
RUN mkdir -p /run /var/lib/nginx /var/lib/php /var/run/sshd && \
    chmod -R 777 /run /var/lib/nginx /var/lib/php /etc/php/7.2/fpm/php.ini && \
    chmod 744 /var/run/sshd

RUN su -c 'composer global require "laravel/installer"' - dev

COPY files /
COPY ./run.sh /usr/local/bin/run.sh

EXPOSE 22 80 8080 443 9000 9002

VOLUME ["/var/www/feed"]
VOLUME ["/var/www/profile"]
VOLUME ["/var/www/app"]
VOLUME ["/etc/nginx/sites-enabled"]

CMD ["/bin/bash", "/usr/local/bin/run.sh"]