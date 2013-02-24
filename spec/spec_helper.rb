require 'pp'
require 'fakefs'
require 'webmock/rspec'

RSpec.configure do |config|
  config.mock_framework = :mocha
end
