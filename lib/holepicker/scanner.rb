require 'holepicker/gem'
require 'holepicker/offline_database'
require 'holepicker/online_database'
require 'holepicker/utils'
require 'rainbow'
require 'set'

module HolePicker
  class Scanner
    SKIPPED_DIRECTORIES = ["-name cached-copy", "-path '*/bundle/ruby'", "-name tmp", "-name '.*'"]
    ROOT_LINE_PATTERN = %r{\b(?:root|DocumentRoot)\s+(.*)/public\b}
    GEMFILE_GEM_PATTERN = %r(^ {4}[^ ])

    def initialize(paths, options = {})
      @paths = paths.is_a?(Array) ? paths : [paths]

      @database = options[:offline] ? OfflineDatabase.load : OnlineDatabase.load

      @ignored = options[:ignored_gems] || []
      @skip = !options[:dont_skip]
      @current = options[:current]
      @roots = options[:follow_roots]
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

    def find_gemfiles_in_path(path)
      skips = SKIPPED_DIRECTORIES.join(" -or ")
      gemfiles = @current ? "-path '*/current/Gemfile.lock'" : "-name 'Gemfile.lock'"

      command = if @skip
        "find -L #{path} \\( #{skips} \\) -prune -or #{gemfiles} -print"
      else
        "find -L #{path} #{gemfiles}"
      end

      run_and_read_lines(command)
    end

    def find_gemfiles_in_configs(path)
      configs = run_and_read_lines("find -L #{path} -type f -or -type l")
      configs = select_existing(configs)

      directories = configs.map { |f| File.read(f).scan(ROOT_LINE_PATTERN) }
      gemfiles = directories.flatten.map { |dir| "#{dir}/Gemfile.lock" }

      select_existing(gemfiles)
    end

    def read_gemfile(path)
      File.readlines(path).select { |l| l =~ GEMFILE_GEM_PATTERN }.map { |l| Gem.new(l) }
    end

    def scan_path(path)
      path = File.expand_path(path)
      gemfiles = @roots ? find_gemfiles_in_configs(path) : find_gemfiles_in_path(path)
      gemfiles.each { |f| scan_gemfile(f) }
    end

    def scan_gemfile(path)
      print "#{path}: "

      gems = read_gemfile(path)
      gems.delete_if { |g| @ignored.include?(g.name) }

      vulnerable_gems = gems.map { |g| [g, vulnerabilities_for_gem(g)] }
      vulnerable_gems.delete_if { |g, v| v.empty? }

      count = vulnerable_gems.length

      if count == 0
        puts "OK"
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
        puts(("#{@matched_gems} vulnerable #{Utils.pluralize(@matched_gems, 'gem')} found in " +
          "#{@matched_gemfiles} #{Utils.pluralize(@matched_gemfiles, 'gemfile')}!").color(:red) + "\n\n")

        @found_vulnerabilities.sort_by(&:id).each do |v|
          puts "[#{v.tag}] #{v.day}: #{v.url}"
        end
      end
    end

    def select_existing(files)
      files.select { |f| File.exist?(f) }
    end

    def run_and_read_lines(command)
      %x(#{command}).lines.map(&:strip)
    end
  end
end
