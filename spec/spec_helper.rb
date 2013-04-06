require 'pp'
require 'coveralls'
require 'fakefs/spec_helpers'
require 'support/spec_helpers'
require 'webmock/rspec'

RSpec.configure do |config|
  config.mock_framework = :mocha

  config.before do
    HolePicker.logger.level = Logger::FATAL
  end

  config.include FakeFS::SpecHelpers
  config.include HolePicker::SpecHelpers
end

Coveralls.wear!
