lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH << lib unless $LOAD_PATH.include?(lib)

require 'holepicker/version'

Gem::Specification.new do |s|
  s.name = "holepicker"
  s.version = HolePicker::VERSION
  s.summary = "A tool for checking gem versions in Gemfile.lock files for known vulnerabilities"
  s.homepage = "http://github.com/jsuder/holepicker"

  s.author = "Jakub Suder"
  s.email = "jakub.suder@gmail.com"

  s.add_dependency 'json', '>= 1.7.7'
  s.add_dependency 'rainbow', '~> 2.0'

  s.files = %w(MIT-LICENSE.txt README.markdown Changelog.markdown Gemfile) + Dir['lib/**/*']

  s.executables = %w(holepicker)
end
