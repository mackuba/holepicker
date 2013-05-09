require 'holepicker/gem'

module HolePicker
  class GemfileParser
    GEM_PATTERN = %r(^ {4}[^ ])

    def initialize(ignored_gems = nil)
      @ignored_gems = ignored_gems || []
    end

    def parse_gemfile(data)
      gem_lines = data.lines.select { |l| l =~ GEM_PATTERN }
      gems = gem_lines.map { |l| Gem.new(l) }
      gems.reject { |g| @ignored_gems.include?(g.name) }
    end
  end
end
