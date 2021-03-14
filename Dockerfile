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