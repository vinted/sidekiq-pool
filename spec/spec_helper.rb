require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'sidekiq/pool'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

$TESTING = true
