require 'holepicker/vulnerability'

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

  def ignoring_errors
    yield
  rescue Exception => e
  end

  def make_vulnerability_json(args = {})
    { 'url' => 'http://cve.org', 'gems' => [], 'date' => '2013-01-01' }.merge(args)
  end

  def make_vulnerability(args = {})
    HolePicker::Vulnerability.new(make_vulnerability_json(args))
  end
end
