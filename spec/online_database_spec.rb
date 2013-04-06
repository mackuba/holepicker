require 'holepicker/online_database'
require 'spec_helper'

module HolePicker
  describe OnlineDatabase do
    describe ".load" do
      let(:version) { '0.1' }
      let(:vulnerabilities) {[
        { 'url' => 'aaa', 'gems' => { 'gema' => ['1.2'] }, 'date' => '2013-01-01' },
        { 'url' => 'bbb', 'gems' => { 'gemb' => ['2.3'] }, 'date' => '2013-01-01' }
      ]}

      let(:json) {{ 'vulnerabilities' => vulnerabilities, 'min_version' => version }}

      before { stub_request(:get, OnlineDatabase::URL).to_return(:body => json.to_json) }

      it "should load the database from remote JSON file" do
        db = OnlineDatabase.load

        db.should be_a(OnlineDatabase)
        db.vulnerabilities.map(&:url).should == vulnerabilities.map { |v| v['url'] }.reverse
      end

      context "if some vulnerabilities are recent" do
        before { Vulnerability.any_instance.stubs(:recent?).returns(false).returns(true) }

        it "should report this" do
          HolePicker.logger.stubs(:info)
          HolePicker.logger.expects(:info).with(regexp_matches(/1 new vulnerability found in the last/))
          HolePicker.logger.expects(:info).with(regexp_matches(/\(gema\): aaa/))

          ignoring_errors { OnlineDatabase.load }
        end
      end

      context "if none of the vulnerabilities are recent" do
        before { Vulnerability.any_instance.stubs(:recent?).returns(false) }

        it "should not report anything" do
          HolePicker.logger.stubs(:info)
          HolePicker.logger.expects(:info).with(regexp_matches(/found in the last/)).never

          ignoring_errors { OnlineDatabase.load }
        end
      end

      context "if gem is compatible with the JSON file" do
        before { OnlineDatabase.any_instance.stubs(:compatible? => true) }

        it "should not exit" do
          expect { OnlineDatabase.load }.not_to raise_error(SystemExit)
        end

        it "should not print any error message" do
          HolePicker.logger.expects(:fail).never

          ignoring_errors { OnlineDatabase.load }
        end
      end

      context "if gem is not compatible with the JSON file" do
        before { OnlineDatabase.any_instance.stubs(:compatible? => false) }

        it "should exit" do
          expect { OnlineDatabase.load }.to raise_error(SystemExit)
        end

        it "should print an error message" do
          HolePicker.logger.expects(:fail)

          ignoring_errors { OnlineDatabase.load }
        end
      end

      context "if JSON file can't be downloaded" do
        before { stub_request(:get, OnlineDatabase::URL).to_timeout }

        it "should exit" do
          expect { OnlineDatabase.load }.to raise_error(SystemExit)
        end

        it "should print an error message" do
          HolePicker.logger.expects(:fail)

          ignoring_errors { OnlineDatabase.load }
        end
      end
    end
  end
end
