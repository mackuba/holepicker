require 'holepicker/scanner'
require 'spec_helper'

module HolePicker
  describe Scanner do
    it "should not raise error" do
      OnlineDatabase.stubs(:load).returns('{}')
      FileFinder.stubs(:find_files).returns([])

      Scanner.new('.').scan
    end
  end
end
