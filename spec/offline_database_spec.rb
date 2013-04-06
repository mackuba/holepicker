require 'holepicker/offline_database'
require 'spec_helper'

module HolePicker
  describe OfflineDatabase do
    describe ".load" do
      let(:version) { '1.2.4' }
      let(:vulnerabilities) {[
        { 'url' => 'aaa', 'gems' => [], 'date' => '2013-01-01' },
        { 'url' => 'bbb', 'gems' => [], 'date' => '2013-01-01' }
      ]}

      let(:json) {{ 'vulnerabilities' => vulnerabilities, 'min_version' => version }}
      let(:path) { File.expand_path('../../lib/holepicker/data/data.json', __FILE__) }

      before { create_file(path, json.to_json) }

      it "should load the database from the default json file" do
        db = OfflineDatabase.load

        db.should be_a(OfflineDatabase)
        db.vulnerabilities.map(&:url).should == vulnerabilities.map { |v| v['url'] }.reverse
      end
    end
  end
end
