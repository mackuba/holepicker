require 'holepicker/config_gemfile_finder'
require 'spec_helper'

module HolePicker
  describe ConfigGemfileFinder do
    describe "#find_gemfiles" do
      let(:reader1) { stub(:find_gemfiles => []) }
      let(:reader2) { stub(:find_gemfiles => []) }
      let(:paths) {[ '/etc/config1', '/etc/config2' ]}

      it "should find config files in given path" do
        FileFinder.expects(:find_files).with('/etc', '-type f -or -type l').returns(paths)

        subject.find_gemfiles('/etc')
      end

      it "should calculate absolute path if path is relative" do
        FileFinder.expects(:find_files).with('/var', '-type f -or -type l').returns(paths)

        subject.find_gemfiles('/etc/nginx/../../var')
      end

      context "if config files are found" do
        before { paths.each { |f| create_file(f) }}

        it "should run use ConfigReaders to find gemfiles in each found config" do
          FileFinder.stubs(:find_files).returns(paths)
          ConfigReader.expects(:new).with(paths[0]).returns(reader1)
          ConfigReader.expects(:new).with(paths[1]).returns(reader2)
          reader1.expects(:find_gemfiles)
          reader2.expects(:find_gemfiles)

          subject.find_gemfiles('/etc')
        end

        it "should collect returned gemfiles on a single list" do
          FileFinder.stubs(:find_files).returns(paths)
          ConfigReader.any_instance.stubs(:find_gemfiles).
            returns(['/var/www/aaa', '/var/www/bbb']).
            returns(['/var/www/ccc'])

          subject.find_gemfiles('/etc/').should == ['/var/www/aaa', '/var/www/bbb', '/var/www/ccc']
        end
      end

      context "if some of the returned config files don't exist" do
        # this might happen if find command finds broken symlinks

        before { create_file(paths[1]) }

        it "should ignore not existing configs" do
          FileFinder.stubs(:find_files).returns(paths)
          ConfigReader.expects(:new).with(paths[0]).never
          ConfigReader.expects(:new).with(paths[1]).returns(reader1)

          subject.find_gemfiles('/etc')
        end
      end
    end
  end
end
