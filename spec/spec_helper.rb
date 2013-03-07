require 'pp'
require 'fakefs/spec_helpers'
require 'support/spec_helpers'
require 'webmock/rspec'

RSpec.configure do |config|
  config.mock_framework = :mocha

  config.include FakeFS::SpecHelpers
  config.include HolePicker::SpecHelpers
end
