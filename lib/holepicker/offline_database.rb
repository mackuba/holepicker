require 'holepicker/database'
require 'holepicker/logger'

module HolePicker
  class OfflineDatabase < Database
    include HasLogger

    OFFLINE_JSON_FILE = File.expand_path('../data/data.json', __FILE__)

    def self.load
      load_from_json_file(File.read(OFFLINE_JSON_FILE))
    rescue Exception => e
      logger.fail "Can't load local data file: #{e}"
      exit 1
    end
  end
end
