# encoding: utf-8

require 'holepicker/config_gemfile_finder'
require 'holepicker/direct_gemfile_finder'
require 'holepicker/gemfile_parser'
require 'holepicker/logger'
require 'holepicker/offline_database'
require 'holepicker/online_database'
require 'holepicker/utils'
require 'set'

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
      @found_vulnerabilities = Set.new
      @scanned_gemfiles = 0
      @matched_gemfiles = 0
      @matched_gems = 0

      if @stdin
        scan_gemfile(STDIN.read, nil)
      else
        logger.info "Looking for gemfiles..."

        @paths.each { |p| scan_path(p) }
      end

      print_report

      @matched_gems == 0
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
      else
        logger.print "#{label}: ", Logger::ERROR
        logger.fail "#{count} vulnerable #{Utils.pluralize(count, 'gem')} found!"

        vulnerable_gems.each do |gem, vulnerabilities|
          logger.error "- #{gem} [#{vulnerabilities.map(&:tag).join(',')}]"

          @found_vulnerabilities.merge(vulnerabilities)
          @matched_gems += 1
        end

        @matched_gemfiles += 1

        logger.error
      end

      @scanned_gemfiles += 1
    end

    def print_report
      if @scanned_gemfiles == 0
        logger.warn "No gemfiles found - are you sure the paths are correct?"
      elsif @matched_gemfiles == 0
        logger.info "No vulnerabilities found."
      else
        gems = Utils.pluralize(@matched_gems, 'gem')
        gemfiles = Utils.pluralize(@matched_gemfiles, 'gemfile')

        logger.fail "#{@matched_gems} vulnerable #{gems} found in #{@matched_gemfiles} #{gemfiles}!\n"

        @found_vulnerabilities.sort_by(&:id).each do |v|
          logger.error "[#{v.tag}] #{v.day}: #{v.url}"
        end

        if @found_vulnerabilities.any?(&:note)
          logger.error

          @found_vulnerabilities.select(&:note).each do |v|
            logger.error "[#{v.tag}] #{v.note}"
          end
        end
      end
    end
  end
end
