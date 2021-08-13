# syntax=docker/dockerfile:1
FROM ruby:2.6.6
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
WORKDIR /ratel
COPY Gemfile /ratel/Gemfile
COPY Gemfile.lock /ratel/Gemfile.lock
RUN gem install bundler
RUN bundle install

EXPOSE 4567

# Configure the main process to run when running the image
CMD ["rackup", "-o", "0.0.0.0"]
