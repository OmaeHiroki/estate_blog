# ベースイメージを指定
FROM php:7.4-fpm-buster 
# コマンドのシェル形式に使用されるデフォルトのシェルをオーバーライド
SHELL ["/bin/bash", "-oeux", "pipefail", "-c"]

# 環境変数設定
ENV COMPOSER_ALLOW_SUPERUSER=1 \
  COMPOSER_HOME=/composer

# composerインストール
COPY --from=composer:1.10 /usr/bin/composer /usr/bin/composer

# Laravelの実行に必要なライブラリのインストール
RUN apt-get update && \
  apt-get -y install git unzip libzip-dev libicu-dev libonig-dev \
  zlib1g-dev \ 
  libjpeg-dev \
  libpng-dev \
  libfreetype6-dev \
  libjpeg62-turbo-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*
  
# PHP拡張ライブラリのインストール
RUN docker-php-ext-install pdo_mysql zip bcmath
# PHP拡張用モジュールの設定 GDのfreetypeとjpegを有効
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
# PHP拡張モジュールのGD（画像変換モジュール）をインストール
RUN docker-php-ext-install -j$(nproc) gd 
RUN pwd

# PHP設定ファイルを設置
COPY ./php.ini /usr/local/etc/php/php.ini
RUN pwd

# sshキーを設置
RUN mkdir /root/.ssh
COPY .ssh/ /root/.ssh/
RUN pwd


WORKDIR /var/www/html
# ファイルダウンロード
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# 解凍実施
RUN unzip awscliv2.zip
# インストール
RUN ./aws/install
RUN pwd

WORKDIR /work
