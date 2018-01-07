FROM ruby:2.3.1

# Create application root
RUN mkdir /mycrypto
WORKDIR /mycrypto

# This stanza is an optimization such that we only do a dependency update on
# image builds when the Gemfiles change
COPY ./Gemfile ./Gemfile.lock /mycrypto/
# Make sure we're using the bundler version noted in the Gemfile
RUN gem install bundler
RUN bundle install

# Move the rest of the app over
COPY ./ /mycrypto

EXPOSE 8080

CMD [ "bundle", "exec", "unicorn" ]
