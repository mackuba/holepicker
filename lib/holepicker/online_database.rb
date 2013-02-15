require 'holepicker/database'
require 'holepicker/utils'
require 'net/http'

module HolePicker
  class OnlineDatabase < Database
    # TODO temporary link
    URL='https://gist.github.com/psionides/d2b89535e55e5cf4e357/raw/96370d66f64b65909800186d1b07ce970f6a5343/data.json'
    NEW_VULNERABILITY_DAYS = 7
    NEW_VULNERABILITY_TIME = NEW_VULNERABILITY_DAYS * 86400

    def self.load
      puts "Fetching list of vulnerabilities..."

      load_from_json_file(http_get(URL)).tap do |db|
        report_new_vulnerabilities(db)
      end
    rescue Exception => e
      puts "Can't download latest data file: #{e}"
      exit 1
    end

    def self.report_new_vulnerabilities(db)
      new_vulnerabilities = db.vulnerabilities.select { |v| v.date > Time.now - NEW_VULNERABILITY_TIME }
      count = new_vulnerabilities.length

      if count > 0
        puts "#{count} new #{Utils.pluralize(count, 'vulnerability')} found in the last #{NEW_VULNERABILITY_DAYS} days:"

        new_vulnerabilities.each do |v|
          puts "#{v.day} (#{v.gem_names.join(', ')}): #{v.url}"
        end

        puts
      end
    end

    def self.http_get(url)
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      response = http.get(uri.request_uri)
      response.body
    end
  end
end
