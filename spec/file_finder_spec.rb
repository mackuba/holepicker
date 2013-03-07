require 'holepicker/file_finder'
require 'spec_helper'

describe HolePicker::FileFinder do
  subject { HolePicker::FileFinder }

  it "should call the 'find' command with given arguments" do
    subject.expects(:`).with("find -L /usr -type f -and -name 'git*'").returns('')

    subject.find_files('/usr', "-type f -and -name 'git*'")
  end

  it "should divide the output into lines and strip them" do
    subject.stubs(:`).returns("one\ntwo\nthree\n")

    subject.find_files('/', '-name foo').should == ['one', 'two', 'three']
  end
end