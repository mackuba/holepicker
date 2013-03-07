module HolePicker::SpecHelpers
  def create_parent_directory(path)
    dir = File.dirname(path)
    return if dir == '/'

    create_parent_directory(dir)
    Dir.mkdir(dir) unless File.exist?(dir)
  end

  def create_file(path, contents = '')
    create_parent_directory(path)

    File.open(path, 'w') { |f| f.write(contents) }
  end

  def replace_const(klass, name, value)
    previous = klass.const_get(name)

    klass.class_eval do
      remove_const(name)
      const_set(name, value)
    end

    previous
  end
end
