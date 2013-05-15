# encoding: utf-8

require 'holepicker/config_gemfile_finder'
require 'holepicker/direct_gemfile_finder'
require 'holepicker/gemfile_parser'
require 'holepicker/logger'
require 'holepicker/offline_database'
require 'holepicker/online_database'
require 'holepicker/scan_reporter'
require 'holepicker/utils'

module HolePicker
  class Scanner
    include HasLogger

    def initialize(paths, options = {})
      @paths = paths.is_a?(Array) ? paths : [paths]
      @stdin = options[:stdin]

      @database = options[:offline] ? OfflineDatabase.load : OnlineDatabase.load

      @finder = if options[:follow_roots]
        ConfigGemfileFinder.new
      else
        DirectGemfileFinder.new(
          :skip_ignored => !options[:dont_skip],
          :only_current => options[:current]
        )
      end

      @parser = GemfileParser.new(options[:ignored_gems])
    end

    def scan
      @reporter = ScanReporter.new

      if @stdin
        scan_gemfile(STDIN.read, nil)
      else
        logger.info "Looking for gemfiles..."

        @paths.each { |p| scan_path(p) }
      end

      @reporter.print_report

      @reporter.success?
    end


    private

    def vulnerabilities_for_gem(gem)
      @database.vulnerabilities.select { |v| v.gem_vulnerable?(gem) }
    end

    def scan_path(path)
      @finder.find_gemfiles(path).each { |f| scan_gemfile(File.read(f), f) }
    end

    def scan_gemfile(data, path)
      gems = @parser.parse_gemfile(data)

      vulnerable_gems = gems.map { |g| [g, vulnerabilities_for_gem(g)] }
      vulnerable_gems.delete_if { |g, v| v.empty? }

      count = vulnerable_gems.length
      label = path || "Scanning gemfile"

      if count == 0
        logger.print "#{label}: "
        logger.success "✔"

        @reporter.add_safe_gemfile(path)
      else
        logger.print "#{label}: ", Logger::ERROR
        logger.fail "#{count} vulnerable #{Utils.pluralize(count, 'gem')} found!"

        vulnerable_gems.each do |gem, vulnerabilities|
          logger.error "- #{gem} [#{vulnerabilities.map(&:tag).join(',')}]"

          @reporter.add_vulnerable_gem(gem, vulnerabilities)
        end

        @reporter.add_vulnerable_gemfile(path)

        logger.error
      end
    end
  end
end
