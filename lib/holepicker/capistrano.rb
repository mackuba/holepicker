require 'holepicker/scanner'

Capistrano::Configuration.instance.load do
  set(:holepicker_offline, false) unless exists?(:holepicker_offline)
  set(:holepicker_dont_skip, false) unless exists?(:holepicker_dont_skip)
  set(:holepicker_ignored_gems, []) unless exists?(:holepicker_ignored_gems)

  before "deploy:update_code", "holepicker"

  namespace :holepicker do
    desc "Look for vulnerabilities in your Gemfile"
    task :default, :roles => :app do
      options = {
        :ignored_gems => holepicker_ignored_gems,
        :offline => holepicker_offline,
        :dont_skip => holepicker_dont_skip
      }

      gemfile_lock = "#{ENV['BUNDLE_GEMFILE']}.lock"
      success = HolePicker::Scanner.new(gemfile_lock, options).scan
      unless success
        raise Capistrano::CommandError.new("HOLEPICKER found vulnerabilities!")
      end
    end
  end
end
