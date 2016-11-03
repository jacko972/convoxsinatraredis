FROM ruby:2.3

ENV BUNDLER_VERSION 1.13.6
RUN apt-get update
RUN apt-get update -qq && apt-get install -y build-essential
RUN apt-get install \
  ca-certificates \
  openssl \
  gem install bundler -v "$BUNDLER_VERSION" && \
  bundle config --global silence_root_warning 1 && \
  mkdir /app

WORKDIR /app

# cache bundler
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

# copy the rest of the app
COPY . /app
