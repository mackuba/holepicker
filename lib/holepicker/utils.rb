module HolePicker
  module Utils
    def self.pluralize(count, name)
      if count == 1
        name
      else
        name.gsub(/y$/, 'ie') + 's'
      end
    end
  end
end
