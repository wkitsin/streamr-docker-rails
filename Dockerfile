# From one of the official ruby images
FROM ruby:2.4

# Available (and reused) args
# Use --build-arg APP_PATH=/usr/app to use another app directory
# Use --build-arg PORT=5000 to use another app default port
ARG APP_PATH='/app'
ARG PORT=3000

# Setting env up
ENV RAILS_ENV='production'
ENV RAKE_ENV='production'

# Installing required packages
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN apt-get install -y imagemagick\
  && apt-get install -y vim

# Configuring main directory
RUN mkdir -p $APP_PATH
WORKDIR $APP_PATH

# Adding gems
COPY Gemfile* ./
RUN bundle install --jobs 20 --retry 5 --without development test

# Adding project files
COPY . ./
RUN bundle exec rake DATABASE_URL=postgres:does_not_exist assets:precompile

EXPOSE $PORT
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
