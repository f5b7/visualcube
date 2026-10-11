FROM php:8.2-apache

RUN apt-get update \
 && apt-get install -y imagemagick \
 && rm -rf /var/lib/apt/lists/*

COPY . /var/www/html/
