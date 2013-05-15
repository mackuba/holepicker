require 'holepicker/offline_database'
require 'spec_helper'

module HolePicker
  describe OfflineDatabase do
    describe ".load" do
      let(:version) { '1.2.4' }
      let(:vulnerabilities) { [make_vulnerability_json, make_vulnerability_json] }
      let(:json) {{ 'vulnerabilities' => vulnerabilities, 'min_version' => version }}
      let(:path) { File.expand_path('../../lib/holepicker/data/data.json', __FILE__) }

      context "if the file is present" do
        before { create_file(path, json.to_json) }

        it "should load the database from the default json file" do
          db = OfflineDatabase.load

          db.should be_a(OfflineDatabase)
          db.vulnerabilities.map(&:url).should == vulnerabilities.map { |v| v['url'] }.reverse
        end
      end

      context "if the file can't be loaded" do
        it "should exit" do
          expect { OfflineDatabase.load }.to raise_error(SystemExit)
        end

        it "should print an error message" do
          HolePicker.logger.expects(:fail)

          ignoring_errors { OfflineDatabase.load }
        end
      end
    end
  end
end
