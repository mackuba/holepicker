require 'holepicker/gem'
require 'holepicker/gemfile_parser'
require 'spec_helper'

module HolePicker
  describe GemfileParser do
    let(:ignored) { nil }

    let(:data) {
      [
        "GEM",
        "  remote: http://rubygems.org/",
        "  specs:",
        "    addressable (2.2.8)",
        "    colorize (0.5.8)",
        "      multi_json (~> 1.3)"
      ].join("\n")
    }

    subject { GemfileParser.new(ignored) }

    it "should parse gemfile and create Gem objects" do
      gems = subject.parse_gemfile(data)

      gems.should have(2).elements
      gems.each { |g| g.should be_a(Gem) }
      gems.map(&:name).should == ['addressable', 'colorize']
      gems.map(&:version).map(&:to_s).should == ['2.2.8', '0.5.8']
    end

    context "if some gems should be ignored" do
      let(:ignored) { ['addressable'] }

      it "should exclude them" do
        gems = subject.parse_gemfile(data)

        gems.should have(1).element
        gems.first.name.should == 'colorize'
      end
    end
  end
end
