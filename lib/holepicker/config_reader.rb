module HolePicker
  class ConfigReader
    ROOT_LINE_PATTERN = %r{\b(?:root|DocumentRoot)\s+(.*)/public\b}

    def initialize(path)
      @contents = File.read(path)
    end

    def find_gemfiles
      @contents.scan(ROOT_LINE_PATTERN).map { |result| "#{result.first}/Gemfile.lock" }.select { |f| File.exist?(f) }
    end
  end
end
