source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end
ruby "2.6.4"
# gem 'googleauth', '~> 1.0'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0'
gem 'jwt'
# Use sqlite3 as the database for Active Record
gem 'mysql2'
gem 'devise'
gem 'ransack'
gem 'rqrcode'
gem 'paperclip'
gem 'telephone_number'  
gem 'cancan'
gem 'bootstrap', '~> 4.6'
gem 'sassc-rails'
gem 'jquery-rails'
# gem 'bootstrap-sass'
gem 'breadcrumbs_on_rails', '~> 3.0.1'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'cocoon'
gem 'omniauth-facebook'
gem 'ruby-saml', '~> 1.15'
gem 'oauth2', '~> 2.0'
gem 'attr_encrypted', '~> 3.1'
gem 'pry'
gem 'activerecord-import'
gem 'grover'
#gem 'wdm'
gem 'rack-cors'
gem 'fugit'
gem 'sidekiq'
gem 'razorpay'
gem 'wicked_pdf'
# gem 'wkhtmltopdf-binary'
gem 'will_paginate'
gem 'whenever', require: false
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'caxlsx'
gem 'caxlsx_rails'
gem 'roo'
gem 'roo-xls'
gem 'googleauth'
gem 'prawn'
gem 'prawn-table'
gem 'carrierwave', '~> 2.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
gem 'sinatra'
gem 'dotenv'
gem 'aws-sdk', '~> 3'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'pry-rails'
  # gem 'pry-byebug'
  gem 'pry-byebug', '~> 3.8'
  gem 'awesome_print'
  gem 'hirb'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
gem 'listen'
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
# gem 'pg'