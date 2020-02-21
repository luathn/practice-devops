FROM ruby:2.6.5
RUN apt-get update -qq && \
  apt-get install -y nodejs \

ENV APP_ROOT /webapp
RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT

COPY Gemfile $APP_ROOT/Gemfile
COPY Gemfile.lock $APP_ROOT/Gemfile.lock
RUN bundle install
COPY . $APP_ROOT

RUN ["chmod", "+x", "startup.sh"]
