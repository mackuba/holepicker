# encoding: utf-8

require 'holepicker/gem'
require 'holepicker/config_gemfile_finder'
require 'holepicker/direct_gemfile_finder'
require 'holepicker/offline_database'
require 'holepicker/online_database'
require 'holepicker/utils'
require 'rainbow'
require 'set'

module HolePicker
  class Scanner
    GEMFILE_GEM_PATTERN = %r(^ {4}[^ ])

    def initialize(paths, options = {})
      @paths = paths.is_a?(Array) ? paths : [paths]

      @database = options[:offline] ? OfflineDatabase.load : OnlineDatabase.load

      @finder = if options[:follow_roots]
        ConfigGemfileFinder.new
      else
        DirectGemfileFinder.new(
          skip_ignored: !options[:dont_skip],
          only_current: options[:current]
        )
      end

      @ignored = options[:ignored_gems] || []
    end

    def scan
      puts "Looking for gemfiles..."

      @found_vulnerabilities = Set.new
      @scanned_gemfiles = 0
      @matched_gemfiles = 0
      @matched_gems = 0

      @paths.each { |p| scan_path(p) }

      print_report

      @matched_gems == 0
    end


    private

    def vulnerabilities_for_gem(gem)
      @database.vulnerabilities.select { |v| v.gem_vulnerable?(gem) }
    end

    def read_gemfile(path)
      File.readlines(path).select { |l| l =~ GEMFILE_GEM_PATTERN }.map { |l| Gem.new(l) }
    end

    def scan_path(path)
      @finder.find_gemfiles(path).each { |f| scan_gemfile(f) }
    end

    def scan_gemfile(path)
      print "#{path}: "

      gems = read_gemfile(path)
      gems.delete_if { |g| @ignored.include?(g.name) }

      vulnerable_gems = gems.map { |g| [g, vulnerabilities_for_gem(g)] }
      vulnerable_gems.delete_if { |g, v| v.empty? }

      count = vulnerable_gems.length

      if count == 0
        puts "✔".color(:green)
      else
        puts "#{count} vulnerable #{Utils.pluralize(count, 'gem')} found!".color(:red)

        vulnerable_gems.each do |gem, vulnerabilities|
          puts "- #{gem} [#{vulnerabilities.map(&:tag).join(',')}]"

          @found_vulnerabilities.merge(vulnerabilities)
          @matched_gems += 1
        end

        @matched_gemfiles += 1

        puts
      end

      @scanned_gemfiles += 1
    end

    def print_report
      if @scanned_gemfiles == 0
        puts "No gemfiles found - are you sure the paths are correct?".color(:red)
      elsif @matched_gemfiles == 0
        puts "No vulnerabilities found."
      else
        gems = Utils.pluralize(@matched_gems, 'gem')
        gemfiles = Utils.pluralize(@matched_gemfiles, 'gemfile')

        warning = "#{@matched_gems} vulnerable #{gems} found in #{@matched_gemfiles} #{gemfiles}!\n"
        puts warning.color(:red)

        @found_vulnerabilities.sort_by(&:id).each do |v|
          puts "[#{v.tag}] #{v.day}: #{v.url}"
        end
      end
    end
  end
end
