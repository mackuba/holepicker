require 'holepicker/config_reader'
require 'holepicker/file_finder'

module HolePicker
  class ConfigGemfileFinder
    def find_gemfiles(path)
      configs = find_configs(path)
      configs.map { |f| ConfigReader.new(f).find_gemfiles }.flatten
    end

    private

    def find_configs(path)
      full_path = File.expand_path(path)

      FileFinder.find_files(full_path, '-type f -or -type l').select { |f| File.exist?(f) }
    end
  end
end
