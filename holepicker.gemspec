lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH << lib unless $LOAD_PATH.include?(lib)

require 'holepicker/version'

Gem::Specification.new do |s|
  s.name = "holepicker"
  s.version = HolePicker::VERSION
  s.summary = "A tool for checking gem versions in Gemfile.lock files for known vulnerabilities"
  s.homepage = "http://github.com/psionides/holepicker"

  s.author = "Jakub Suder"
  s.email = "jakub.suder@gmail.com"

  s.add_dependency 'json', '>= 1.7.7'
  s.add_dependency 'rainbow', '>= 1.1.4'

  s.files = %w(MIT-LICENSE README.markdown Changelog.markdown Gemfile Gemfile.lock) + Dir['lib/**/*']

  s.executables = %w(holepicker)
end
