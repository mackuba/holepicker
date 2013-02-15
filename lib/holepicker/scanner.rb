require 'find'
require 'holepicker/gem'
require 'holepicker/offline_database'
require 'holepicker/online_database'
require 'holepicker/utils'
require 'rainbow'

module HolePicker
  class Scanner
    SKIPPED_DIRECTORIES = ["-name cached-copy", "-path '*/bundle/ruby'", "-name tmp", "-name '.*'"]

    def initialize(paths, options = {})
      @paths = paths.is_a?(Array) ? paths : [paths]
      @options = options || {}
      @database = options[:offline] ? OfflineDatabase.load : OnlineDatabase.load
      @ignored = options[:ignored_gems] || []
    end

    def scan
      @paths.each { |p| scan_path(p) }
    end


    private

    def vulnerabilities_for_gem(gem)
      @database.vulnerabilities.select { |v| v.gem_vulnerable?(gem) }
    end

    def find_gemfiles_in_path(path)
      skips = SKIPPED_DIRECTORIES.join(" -or ")
      %x(find -L #{path} \\( #{skips} \\) -prune -or -name 'Gemfile.lock' -print).lines.map(&:strip)
    end

    def read_gemfile(path)
      File.readlines(path).select { |l| l =~ /^ {4}[^ ]/ }.map { |l| Gem.new(l) }
    end

    def scan_path(path)
      find_gemfiles_in_path(path).each { |f| scan_gemfile(f) }
    end

    def scan_gemfile(path)
      print "#{path}: "

      gems = read_gemfile(path)
      gems.delete_if { |g| @ignored.include?(g.name) }

      vulnerable_gems = gems.select { |g| vulnerabilities_for_gem(g).length > 0 }
      count = vulnerable_gems.length

      if count == 0
        puts "OK"
      else
        puts "#{count} vulnerable #{Utils.pluralize(count, 'gem')} found!".color(:red)

        vulnerable_gems.each { |gem, list| puts "- #{gem}" }

        puts
      end
    end
  end
end
