# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = "0.28.6"

gem "decidim", DECIDIM_VERSION
gem "decidim-pua", path: "."

gem "puma", "~> 6.2"
gem "uglifier"
gem "bootsnap"
gem "doorkeeper"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION
  gem "rspec-rails", '~> 6.0'
  gem 'shoulda-matchers', '~> 5.0'
end

group :development do
  gem "faker", "~> 3.2"
  gem "letter_opener_web"
  gem "listen"
  gem "spring"
  gem "spring-watcher-listen"
  gem "sqlite3"
  gem "web-console"
end

