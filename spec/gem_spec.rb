require 'holepicker/gem'
require 'spec_helper'

describe HolePicker::Gem do
  let(:gem) { HolePicker::Gem.new(line) }

  context "if proper gem line from gemfile is passed" do
    let(:name) { 'skynet-sdk' }
    let(:version) { '0.9.9' }
    let(:line) { "#{name} (#{version})" }

    it "should not raise any errors" do
      expect { gem }.not_to raise_error
    end

    it "should extract gem name" do
      gem.name.should == name
    end

    it "should extract gem version as a Gem::Version" do
      gem.version.should be_an(Gem::Version)
      gem.version.to_s.should == version
    end
  end

  context "if gem line is not correct" do
    let(:line) { "remote: http://rubygems.org" }

    it "should raise an error" do
      expect { gem }.to raise_error
    end
  end
end
