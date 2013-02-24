require 'holepicker/offline_database'
require 'spec_helper'

describe HolePicker::OfflineDatabase do
  describe ".load" do
    let(:version) { '1.2.4' }
    let(:vulnerabilities) {[
      { 'url' => 'aaa', 'gems' => [], 'date' => '2013-01-01' },
      { 'url' => 'bbb', 'gems' => [], 'date' => '2013-01-01' }
    ]}

    let(:json) {{ 'vulnerabilities' => vulnerabilities, 'min_version' => version }}
    let(:path) { File.expand_path('../../lib/holepicker/data/data.json', __FILE__) }

    def create_parent_directory(path)
      dir = File.dirname(path)
      return if dir == '/'

      create_parent_directory(dir)
      Dir.mkdir(dir)
    end

    before do
      create_parent_directory(path)
      File.open(path, "w") { |f| f.write(json.to_json) }
    end

    it "should load the database from the default json file" do
      db = HolePicker::OfflineDatabase.load

      db.should be_a(HolePicker::OfflineDatabase)
      db.vulnerabilities.map(&:url).should == vulnerabilities.map { |v| v['url'] }.reverse
    end
  end
end
