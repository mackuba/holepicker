require 'holepicker/config_reader'
require 'spec_helper'

module HolePicker
  describe ConfigReader do
    let(:config_path) { '/etc/config' }
    let(:config) { '' }

    subject { ConfigReader.new(config_path) }

    before do
      create_file(config_path, config)
    end

    def self.it_should_find_gemfiles
      before { create_parent_directory(project_path) }

      let(:project_path) { '/home/deploy/app/current' }
      let(:gemfile_path) { project_path + '/Gemfile.lock' }

      context "if a Gemfile.lock exists at that path" do
        before { create_file(gemfile_path) }

        it "should return the path" do
          subject.find_gemfiles.should == [gemfile_path]
        end
      end

      context "if a Gemfile.lock doesn't exist at that path" do
        it "should not return the path" do
          subject.find_gemfiles.should == []
        end
      end
    end

    context "if Nginx config 'root' lines are found" do
      let(:config) { %(
        server_name foo.pl;
        root #{project_path}/public;
        rack_env production;
      )}

      it_should_find_gemfiles
    end

    context "if Apache config 'DocumentRoot' lines are found" do
      let(:config) { %(
        ServerName foo.pl
        DocumentRoot #{project_path}/public
        RailsEnv production
      )}

      it_should_find_gemfiles
    end
  end
end
