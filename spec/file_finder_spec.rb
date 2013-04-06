require 'holepicker/file_finder'
require 'spec_helper'

module HolePicker
  describe FileFinder do
    it "should call the 'find' command with given arguments" do
      FileFinder.expects(:`).with("find -L /usr -type f -and -name 'git*'").returns('')

      FileFinder.find_files('/usr', "-type f -and -name 'git*'")
    end

    it "should divide the output into lines and strip them" do
      FileFinder.stubs(:`).returns("one\ntwo\nthree\n")

      FileFinder.find_files('/', '-name foo').should == ['one', 'two', 'three']
    end
  end
end
