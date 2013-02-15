require 'holepicker/database'

module HolePicker
  class OfflineDatabase < Database
    OFFLINE_JSON_FILE = File.expand_path('../data/data.json', __FILE__)

    def self.load
      load_from_json_file(File.read(OFFLINE_JSON_FILE))
    rescue Exception => e
      puts "Can't load local data file: #{e}"
      exit 1
    end
  end
end
