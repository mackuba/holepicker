require 'holepicker/direct_gemfile_finder'
require 'spec_helper'

module HolePicker
  describe DirectGemfileFinder do
    let(:path) { '/etc' }

    describe "#find_gemfiles" do
      before { subject.stubs(:skipped_directories).returns('SKIP') }

      it "should find gemfiles in given path" do
        FileFinder.expects(:find_files).
          with(path, "\\( SKIP \\) -prune -or -name 'Gemfile.lock' -print").
          returns(['1', '2'])

        subject.find_gemfiles(path).should == ['1', '2']
      end

      context "if passed path is relative" do
        it "should expand it" do
          FileFinder.expects(:find_files).with('/usr', anything)

          subject.find_gemfiles('/usr/local/..')
        end
      end

      context "if :only_current => true is passed" do
        subject { DirectGemfileFinder.new(:only_current => true) }

        it "should include only gemfiles in 'current'" do
          FileFinder.expects(:find_files).with(path, "\\( SKIP \\) -prune -or -path '*/current/Gemfile.lock' -print")

          subject.find_gemfiles(path)
        end
      end

      context "if :skip_ignored => false is passed" do
        subject { DirectGemfileFinder.new(:skip_ignored => false) }

        it "should not skip files that would normally be ignored" do
          FileFinder.expects(:find_files).with(path, "-name 'Gemfile.lock'")

          subject.find_gemfiles(path)
        end
      end
    end

    describe "#skipped_directories" do
      before { @skipped = replace_const(DirectGemfileFinder, 'SKIPPED_DIRECTORIES', ['a', 'b', 'c']) }

      it "should return list of directory patterns joined with '-or'" do
        subject.send(:skipped_directories).should == 'a -or b -or c'
      end

      after { replace_const(DirectGemfileFinder, 'SKIPPED_DIRECTORIES', @skipped) }
    end
  end
end
