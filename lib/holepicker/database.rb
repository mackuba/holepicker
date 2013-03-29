require 'holepicker/version'
require 'holepicker/vulnerability'
require 'json'
require 'rubygems'

module HolePicker
  class Database
    attr_reader :vulnerabilities

    def self.load_from_json_file(data)
      new(JSON.parse(data))
    end

    def initialize(json)
      @vulnerabilities = json['vulnerabilities'].reverse.map { |v| Vulnerability.new(v) }
      @min_version = ::Gem::Version.new(json['min_version'])
    end

    def compatible?
      HolePicker.version >= @min_version
    end
  end
end
