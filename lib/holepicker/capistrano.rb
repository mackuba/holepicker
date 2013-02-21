Capistrano::Configuration.instance.load do
  before "deploy", "holepicker"

  namespace :holepicker do
    desc "Look for vulnerabilities in your Gemfile"
    task :default, :roles => :app do
      gemfile_lock = "#{ENV['BUNDLE_GEMFILE']}.lock"
      # using %x[] untill capistrano's run_locally returns output
      output = %x[bundle exec holepicker #{gemfile_lock}]
      unless $? == 0
        logger.important output
        raise Capistrano::CommandError.new("HOLEPICKER found vulnerabilities!")
      end
    end
  end
end
