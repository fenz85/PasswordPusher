# pwpush-ephemeral
FROM ruby:3.0.2

LABEL maintainer='pglombardo@hey.com'

ENV APP_ROOT=/opt/PasswordPusher
ENV PATH=${APP_ROOT}:${PATH} HOME=${APP_ROOT}

# For the latest yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Required packages
RUN apt-get update -qq && \
    apt-get install -qq -y --assume-yes build-essential apt-utils libpq-dev git curl tzdata libsqlite3-0 libsqlite3-dev zlib1g-dev nodejs yarn && \
    cd /opt && \
    mkdir PasswordPusher && \
    mkdir PasswordPusher/log && \
    touch ${APP_ROOT}/log/private.log

EXPOSE 5100

RUN gem install bundler

WORKDIR ${APP_ROOT}

ENV RACK_ENV=private
ENV RAILS_ENV=private

RUN bundle config set without 'development production test'
RUN bundle config set deployment 'true'

COPY Gemfile Gemfile.lock .
RUN bundle install

COPY app.json package.json babel.config.js yarn.lock .
RUN yarn install

COPY . .

RUN bundle exec rails webpacker:compile
RUN bundle exec rake db:setup

ENTRYPOINT ["bundle", "exec", "puma", "-C", "config/puma.rb", "-e", "private"]
