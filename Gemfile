source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.4'

# Use postgresql as the database for Active Record
gem 'pg'

# Use devise for users
gem 'devise'
gem 'devise-async'
# User cancancan for role based authorization
gem 'cancancan', '~> 1.7'

gem 'sidekiq'
#For Sidekiq's web UI
gem 'sinatra', '>= 1.3.0', :require => nil

#Assets
gem "jquery-datatables-rails"
# Adding HAML.
gem "haml-rails"
# Use jquery as the JavaScript library
gem 'jquery-rails'

# use jquery-ui for the dialog pop up method
#gem 'jquery-ui-rails'

#Bootstrap for styling and modal windows
gem 'bootstrap-sass'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.2'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'


# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby



# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# EVE Gems
# This instance is used because it has been modified to support rails 4, the new CCP domain and the corp contact list api.
gem 'eve',			:git => "https://github.com/islador/eve", :branch => "UpdateErrors"

group :development do
	gem 'annotate'
	gem 'guard-rspec'
	gem 'rspec-rails'
end

group :test do
	gem 'capybara'
	gem 'factory_girl_rails'
	gem 'selenium-webdriver'
	gem 'database_cleaner'
	gem 'vcr'
	gem 'webmock'
end

group :test, :development do
	gem 'spork-rails'
	gem 'guard-spork'
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
