require 'holepicker/database'
require 'holepicker/logger'
require 'holepicker/utils'
require 'net/http'
require 'net/https'

module HolePicker
  class OnlineDatabase < Database
    include HasLogger

    URL = 'https://raw.github.com/jsuder/holepicker/master/lib/holepicker/data/data.json'

    def self.load
      logger.info "Fetching list of vulnerabilities..."

      load_from_json_file(http_get(URL)).tap do |db|
        db.check_compatibility
        db.report_new_vulnerabilities
      end
    rescue SystemExit
      raise
    rescue Exception => e
      logger.fail "Can't download latest data file: #{e}"
      exit 1
    end

    def self.http_get(url)
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = url.start_with?('https')

      response = http.get(uri.request_uri)
      response.body
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
