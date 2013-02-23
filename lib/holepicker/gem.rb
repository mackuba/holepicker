require 'rubygems'

module HolePicker
  class Gem
    GEM_LINE_PATTERN = /([\w\-]+) \(([\d\w]+(\.[\d\w]+)*)(\-\w+)*\)/

    attr_reader :name, :version

    def initialize(line)
      result = line.match(GEM_LINE_PATTERN)
      raise "Invalid gem format: #{line}" unless result

      @name = result[1]
      @version = ::Gem::Version.new(result[2])
    end

    def to_s
      "#{name} (#{version})"
    end
  end
end
