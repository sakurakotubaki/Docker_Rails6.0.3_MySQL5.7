# Rails2.6.6 Rails6.0.3 Docker環境でシンプルCRUD実装

## 作成環境
- Ruby2.6.6
- Rails6.0.3
- MySQL5.7

## プロジェクトフォルダを作る
mkdir Rails_MySQL5.7_Docker

## ファイルの用意
Gemfile Gemfile.lock Dockerfile docker-compose.yml を作成します。
```
$ touch Gemfile Gemfile.lock Dockerfile docker-compose.yml
```

## Gmefile
```
source "https://rubygems.org"
gem "rails", "6.0.3"
```

## Gemfile.lock
何も書かない。

## Dockerfile
```
FROM ruby:2.6.6

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
```

## docker-compose.yml
```
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
```
  
## プロジェクトフォルダの中でrails appを作成
```
$ docker-compose run app rails new . --force --database=mysql
```
## db設定を変更します。
- databse.yml
```
username: root
password: root #docker-compose.ymlのMYSQL_ROOT_PASSWORD
host: db #docker-compose.ymlのサービス名
```
## buildする
$ docker-compose build

## modelを作成
```
$ docker-compose run app rails g model person name:text age:integer mail:text
$ docker-compose run app rails db:create
$ docker-compose run app rails db:migrate
```

## controllerを作成
```
$ docker-compose run app rails g controller people index show edit add 
```
## dockerを起動する
```
$ docker-compose up
```
