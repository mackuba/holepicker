require 'holepicker/database'

module HolePicker
  class OfflineDatabase < Database
    def self.load
      path = File.expand_path('../data/data.json', __FILE__)
      load_from_json_file(File.read(path))
    rescue Exception => e
      puts "Can't load local data file: #{e}"
      exit 1
    end
  end
end
