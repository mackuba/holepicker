require 'holepicker/database'
require 'spec_helper'

module HolePicker
  describe Database do
    let(:version) { '1.2.4' }
    let(:vulnerabilities) {[
      { 'url' => 'aaa', 'gems' => [], 'date' => '2013-01-01' },
      { 'url' => 'bbb', 'gems' => [], 'date' => '2013-01-01' }
    ]}

    let(:json) {{ 'vulnerabilities' => vulnerabilities, 'min_version' => version }}
    let(:db) { Database.new(json) }

    describe "#initialize" do
      it "should extract minimum gem version" do
        mv = db.instance_variable_get("@min_version")

        mv.should be_a(::Gem::Version)
        mv.to_s.should == version
      end

      it "should extract vulnerabilities" do
        db.vulnerabilities.length.should == 2
        db.vulnerabilities.each { |v| v.should be_a(Vulnerability) }
      end

      it "should arrange vulnerabilities in reverse order" do
        db.vulnerabilities[0].url.should == vulnerabilities[1]['url']
        db.vulnerabilities[1].url.should == vulnerabilities[0]['url']
      end
    end

    describe "#compatible?" do
      subject { db.compatible? }

      context "if gem version is newer than min_version" do
        before { HolePicker.stubs(:version => ::Gem::Version.new('1.3.8')) }

        it { should be_true }
      end

      context "if gem version is equal to min_version" do
        before { HolePicker.stubs(:version => ::Gem::Version.new(version)) }

        it { should be_true }
      end

      context "if gem version is older than min_version" do
        before { HolePicker.stubs(:version => ::Gem::Version.new('1.2.1')) }

        it { should be_false }
      end
    end

    describe ".load_from_json_file" do
      it "should build a database from a JSON string" do
        db = Database.load_from_json_file(json.to_json)

        db.should be_a(Database)
        db.vulnerabilities.length.should == 2
      end
    end
  end
end
