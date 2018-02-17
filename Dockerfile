FROM php:7.2
MAINTAINER Nikola Sivkov "erasrz+doker@gmail.com"

RUN apt update && apt install -y \
        git \
        jq \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        build-essential \
        zlib1g-dev \
        zip \
        unzip \
        gnupg2 \

  # node & npm
  && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt update && apt install -y nodejs yarn \

  # composer
  && curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
  && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --snapshot \
  && rm -f /tmp/composer-setup.* \

  # composer parallel install
  && composer global require hirak/prestissimo:^0.3 \

  && docker-php-source extract \

  && docker-php-ext-configure gd \
      --with-gd \
      --with-freetype-dir=/usr/include/ \
      --with-jpeg-dir=/usr/include/ \
      --with-png-dir=/usr/include/ \

  && NPROC=$(getconf _NPROCESSORS_ONLN) \

  && docker-php-ext-install -j${NPROC} gd \
        mysqli \
        opcache \
        pdo_mysql \

  && docker-php-source delete
