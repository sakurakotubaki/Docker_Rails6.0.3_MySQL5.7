# Rails2.6.6 Rails6.0.3 Docker環境でシンプルCRUD実装

## 作成環境
- Ruby2.6.6
- Rails6.0.3
- MySQL5.7

## ファイルの用意
Gemfile Gemfile.lock Dockerfile docker-compose.yml を作成します。

## Gmefile
source "https://rubygems.org"
gem "rails", "6.0.2"

## Gemfile.lock
何も書かない。

## Dockerfile
FROM ruby:2.7.0

RUN apt-get update -qq && \
apt-get install -y \
nodejs \
build-essential

RUN apt-get update && apt-get install -y curl apt-transport-https wget && \
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
apt-get update && apt-get install -y yarn

RUN mkdir /app
WORKDIR /app

ADD Gemfile* /app/

RUN bundle install -j4 --retry 3

ADD . /app

WORKDIR /app

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

## docker-compose.yml
version: '3'
services:
  db:
    image: mysql:5.7
    command: mysqld --character-set-server=utf8 --collation-server=utf8_unicode_ci
    ports:
      - "4306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=root
    volumes:
      - mysql_vol:/var/lib/mysql
  app:
    build: . 
    command: /bin/sh -c "rm -f /app/tmp/pids/server.pid && bundle exec rails s -p 3000 -b '0.0.0.0'"
    volumes:
      - .:/app
    ports:
      - "3000:3000"
    depends_on:
      - db
volumes:
  mysql_vol:
