module HolePicker
  module FileFinder
    def self.find_files(path, options = "")
      %x(find -L #{path} #{options}).lines.map(&:strip)
    end
  end
end
