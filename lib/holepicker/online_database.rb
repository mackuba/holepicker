require 'holepicker/database'
require 'holepicker/logger'
require 'holepicker/utils'
require 'open-uri'

module HolePicker
  class OnlineDatabase < Database
    include HasLogger

    URL = 'https://raw.githubusercontent.com/jsuder/holepicker/master/lib/holepicker/data/data.json'

    def self.load
      logger.info "Fetching list of vulnerabilities..."

      load_from_json_file(http_get(URL))
    rescue SystemExit
      raise
    rescue Exception => e
      logger.fail "Can't download latest data file: #{e}"
      exit 1
    end

    def initialize(json)
      super

      check_compatibility
      report_new_vulnerabilities
    end


    private

    def self.http_get(url)
      open(url).read
    end

    def check_compatibility
      unless compatible?
        logger.fail "You need to upgrade holepicker to version #{@min_version} or later."
        exit 1
      end
    end

    def report_new_vulnerabilities
      new_vulnerabilities = @vulnerabilities.select(&:recent?)
      count = new_vulnerabilities.length

      if count > 0
        logger.info "#{count} new #{Utils.pluralize(count, 'vulnerability')} found in the last " +
          "#{Vulnerability::NEW_VULNERABILITY_DAYS} days:"

        new_vulnerabilities.each do |v|
          logger.info "#{v.day} (#{v.gem_names.join(', ')}): #{v.url}"
        end

        logger.info
      end
    end
  end
end
