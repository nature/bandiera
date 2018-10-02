FROM ruby:2.5.1-alpine

MAINTAINER Darren Oakley <daz.oakley@gmail.com>

RUN apk add --update --no-cache build-base ruby-dev libxml2-dev libxslt-dev postgresql-dev mysql-dev openssl openssl-dev ca-certificates && \
  update-ca-certificates wget

RUN addgroup bandiera && adduser -D -G bandiera -h /home/bandiera bandiera

USER bandiera
WORKDIR /home/bandiera

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install --retry 10 --jobs 4 --without test

COPY . .

EXPOSE 5000

CMD ["puma"]
