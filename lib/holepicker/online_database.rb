require 'holepicker/database'
require 'net/http'

module HolePicker
  class OnlineDatabase < Database
    # TODO temporary link
    URL='https://gist.github.com/psionides/d2b89535e55e5cf4e357/raw/96370d66f64b65909800186d1b07ce970f6a5343/data.json'

    def self.load
      load_from_json_file(http_get(URL))
    rescue Exception => e
      puts "Can't download latest data file: #{e}"
      exit 1
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
