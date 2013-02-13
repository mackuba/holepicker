require 'holepicker/vulnerability'

module HolePicker
  class Database
    attr_reader :vulnerabilities

    def self.load_from_json_file(data)
      new(JSON.parse(data))
    end

    def initialize(json)
      @vulnerabilities = json['vulnerabilities'].map { |v| Vulnerability.new(v) }
    end
  end
end
