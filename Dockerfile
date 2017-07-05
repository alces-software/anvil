FROM ruby:2.4.1

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev
RUN mkdir /app
WORKDIR /app
ADD . /app
RUN ./bin/bundle --full-index && ./bin/bundle install --local
