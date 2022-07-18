FROM ruby:3.1.2

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -\
  && apt-get update -qq && apt-get install -qq --no-install-recommends \
    nodejs postgresql-client \
  && apt-get upgrade -qq \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*\
  && npm install -g yarn@1

WORKDIR /app

COPY Gemfile Gemfile.lock /app/
RUN bundle install

COPY package.json yarn.lock /app/
RUN yarn install

COPY . /app/

ENV RAILS_ENV development
RUN bundle exec rake assets:precompile

CMD bundle exec rails server -b 0.0.0.0
