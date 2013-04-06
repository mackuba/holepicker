require 'holepicker/online_database'
require 'spec_helper'

module HolePicker
  describe OnlineDatabase do
    describe ".load" do
      let(:version) { '0.1' }
      let(:vulnerabilities) {[
        { 'url' => 'aaa', 'gems' => [], 'date' => '2013-01-01' },
        { 'url' => 'bbb', 'gems' => [], 'date' => '2013-01-01' }
      ]}

      let(:json) {{ 'vulnerabilities' => vulnerabilities, 'min_version' => version }}

      before { stub_request(:get, OnlineDatabase::URL).to_return(:body => json.to_json) }

      it "should load the database from remote JSON file" do
        db = OnlineDatabase.load

        db.should be_a(OnlineDatabase)
        db.vulnerabilities.map(&:url).should == vulnerabilities.map { |v| v['url'] }.reverse
      end

      context "if gem is compatible with the JSON file" do
        before { OnlineDatabase.any_instance.stubs(:compatible? => true) }

        it "should not exit" do
          expect { OnlineDatabase.load }.not_to raise_error(SystemExit)
        end
      end

      context "if gem is not compatible with the JSON file" do
        before { OnlineDatabase.any_instance.stubs(:compatible? => false) }

        it "should exit" do
          expect { OnlineDatabase.load }.to raise_error(SystemExit)
        end
      end

      context "if JSON file can't be downloaded" do
        before { stub_request(:get, OnlineDatabase::URL).to_timeout }

        it "should exit" do
          expect { OnlineDatabase.load }.to raise_error(SystemExit)
        end
      end
    end
  end
end
