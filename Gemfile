source 'https://rubygems.org'
ruby '2.1.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'

group :development,:test do
	gem 'rspec-rails'
	gem 'rspec-its'
	gem 'simplecov', :require => false
	gem 'guard-rspec'
	gem 'spork-rails'
	gem 'guard-spork'
	gem 'childprocess'
	gem 'rails-erd'
	gem 'pry-rails'
	gem 'guard-rails'
	gem 'guard-livereload'
	gem 'guard-bundler'
end

group :test do
	gem 'selenium-webdriver', '~> 2.42.0'
	gem 'capybara', '~> 2.3.0'
	gem 'factory_girl_rails'
	gem 'faker'
	gem 'launchy'
end

gem 'mysql2', '~> 0.3.20'
gem 'bootstrap-sass'
gem 'sprockets', '2.11.0'
gem 'bcrypt-ruby', '3.1.2'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.2'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'jquery-turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'
gem 'shoulda'
gem 'date_validator'
gem 'foreigner'
gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'searchkick'
gem 'money'
gem 'money-rails'
gem 'elasticsearch-model'
gem 'elasticsearch-rails'
gem 'geocoder'
gem 'geo_ip'
gem 'stripe'
gem 'wkhtmltopdf-binary'
gem 'wicked_pdf'
gem 'premailer-rails'
gem 'nokogiri'
gem 'acts_as_votable', '~> 0.10.0'
gem 'aws-sdk-v1'
gem 'carrierwave'
gem 'fog'
gem 'figaro'
gem 'mini_magick'
gem 'responders'
gem 'devise' # User management
gem 'elastic-beanstalk'
gem 'font-awesome-rails' # Font-awesome icon
gem 'mail_form' #Forms, mail
gem 'simple_form' #Forms, mail

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

group :production do
	gem 'pg'
	gem 'rails_12factor', '~> 0.0.2'
end
