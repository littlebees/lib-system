FROM ruby:2.7.0-alpine AS setup_env
MAINTAINER fengzheng <fengzheng@me.com>
ENTRYPOINT ["rails"]
#RUN apt update && apt-get install -y build-essential nodejs imagemagick libmariadbclient-dev
# Add `gem 'tzinfo-data'` to the Gemfile. 
# Add `tzdata` to the Dockerfile
# ZInfo::DataSourceNotFound: tzinfo-data is not present. Please add gem 'tzinfo-data' to your Gemfile and run bundle install 
RUN apk update && apk upgrade && apk add --update --no-cache build-base nodejs imagemagick mariadb-dev tzdata

FROM setup_env AS install_gems
RUN mkdir /app
WORKDIR /app
COPY Gemfile* /app/
RUN bundle install

FROM install_gems
COPY . /app
WORKDIR /app
RUN sed -i "s/REPLACE_WITH_SECRET/'$(rake secret)'/g" config/initializers/devise.rb
# The connection was reset
CMD ["s", "--binding", "0.0.0.0"]
