require 'holepicker/logger'
require 'holepicker/utils'
require 'set'

module HolePicker
  class ScanReporter
    include HasLogger

    attr_reader :safe_gemfiles, :vulnerable_gems, :vulnerable_gemfiles, :vulnerabilities

    def initialize
      @safe_gemfiles = []
      @vulnerable_gemfiles = []
      @vulnerable_gems = []
      @vulnerabilities = Set.new
    end

    def add_vulnerable_gem(gem, vulnerabilities)
      @vulnerabilities.merge(vulnerabilities)
      @vulnerable_gems << gem
    end

    def add_vulnerable_gemfile(path)
      @vulnerable_gemfiles << path
    end

    def add_safe_gemfile(path)
      @safe_gemfiles << path
    end

    def success?
      @vulnerable_gems.empty?
    end

    def print_report
      if success?
        if @safe_gemfiles.empty?
          logger.warn "No gemfiles found - are you sure the paths are correct?"
        else
          logger.info "No vulnerabilities found."
        end
      else
        gem_count = @vulnerable_gems.length
        gemfile_count = @vulnerable_gemfiles.length

        gems = Utils.pluralize(gem_count, 'gem')
        gemfiles = Utils.pluralize(gemfile_count, 'gemfile')

        logger.fail "#{gem_count} vulnerable #{gems} found in #{gemfile_count} #{gemfiles}!\n"

        report_vulnerabilities
        print_notes if @vulnerabilities.any?(&:note)
      end
    end


    private

    def report_vulnerabilities
      @vulnerabilities.sort_by(&:id).each do |v|
        logger.error "[#{v.tag}] #{v.day}: #{v.url}"
      end
    end

    def print_notes
      logger.error

      @vulnerabilities.select(&:note).each do |v|
        logger.error "[#{v.tag}] #{v.note}"
      end
    end
  end
end
