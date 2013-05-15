require 'holepicker/scan_reporter'
require 'set'
require 'spec_helper'

module HolePicker
  describe ScanReporter do
    class FakeLogger
      attr_reader :logs

      def initialize
        @logs = []
      end

      def method_missing(name, message = nil)
        @logs << [name, message]
      end
    end

    context "after creation" do
      its(:safe_gemfiles) { should be_empty }
      its(:vulnerable_gemfiles) { should be_empty }
      its(:vulnerable_gems) { should be_empty }

      its(:vulnerabilities) { should be_empty }
      its(:vulnerabilities) { should be_a(Set) }
    end

    describe "#add_vulnerable_gem" do
      let(:vulnerabilities) { [make_vulnerability, make_vulnerability] }

      before { subject.add_vulnerable_gem('rails', vulnerabilities) }

      it "should add the gem to the list of vulnerable gems" do
        subject.vulnerable_gems.should == ['rails']
      end

      it "should add the vulnerabilities to the set" do
        subject.vulnerabilities.to_a.should == vulnerabilities
      end

      context "if a vulnerability was already in the set" do
        before { subject.add_vulnerable_gem('activerecord', [vulnerabilities[0]]) }

        it "should not add it again" do
          subject.vulnerabilities.to_a.should == vulnerabilities
        end
      end
    end

    describe "#add_vulnerable_gemfile" do
      before { subject.add_vulnerable_gemfile('Gemfile.lock') }

      it "should add the gemfile to the list of vulnerable gemfiles" do
        subject.vulnerable_gemfiles.should == ['Gemfile.lock']
      end
    end

    describe "#add_safe_gemfile" do
      before { subject.add_safe_gemfile('Gemfile.lock') }

      it "should add the gemfile to the list of safe gemfiles" do
        subject.safe_gemfiles.should == ['Gemfile.lock']
      end
    end

    describe "#success?" do
      context "if there are vulnerable gems" do
        before { subject.add_vulnerable_gem('rails', [make_vulnerability]) }

        it "should be false" do
          subject.success?.should be_false
        end
      end

      context "if there are no vulnerable gems" do
        it "should be true" do
          subject.success?.should be_true
        end
      end
    end

    describe "#print_report" do
      let(:logger) { FakeLogger.new }

      before { subject.logger = logger }

      context "if no gemfiles were scanned" do
        it "should print a warning message" do
          subject.print_report

          logger.logs.should have(1).entry
          logger.logs[0][0].should == :warn
          logger.logs[0][1].should =~ /no gemfiles found/i
        end
      end

      context "if only safe gemfiles were found" do
        before { subject.add_safe_gemfile('Gemfile.lock') }

        it "should print a success message" do
          subject.print_report

          logger.logs.should have(1).entry
          logger.logs[0][0].should == :info
          logger.logs[0][1].should =~ /no vulnerabilities/i
        end
      end

      context "if vulnerable gemfiles were found" do
        let(:vulnerabilities) { [make_vulnerability, make_vulnerability] }

        before do
          subject.add_vulnerable_gem('rails', vulnerabilities)
          subject.add_vulnerable_gemfile('Gemfile.lock')
        end

        it "should print a failure message" do
          subject.print_report

          logger.logs[0][0].should == :fail
          logger.logs[0][1].should =~ /1 vulnerable gem found in 1 gemfile/i
        end

        it "should properly pluralize 'gem' and 'gemfile'" do
          subject.add_vulnerable_gem('devise', [make_vulnerability])
          subject.add_vulnerable_gemfile('foo/Gemfile.lock')

          subject.print_report

          logger.logs[0][1].should =~ /2 vulnerable gems found in 2 gemfiles/i
        end

        it "should list all vulnerabilities" do
          subject.print_report

          logger.logs[1][0].should == :error
          logger.logs[1][1].should include(vulnerabilities[0].url)
          logger.logs[2][0].should == :error
          logger.logs[2][1].should include(vulnerabilities[1].url)
        end

        context "if some vulnerabilities include additional notes" do
          let(:vulnerabilities) { [make_vulnerability, make_vulnerability('note' => 'argh')] }

          it "should display that note" do
            subject.print_report

            logger.logs.last[0].should == :error
            logger.logs.last[1].should =~ /argh/
          end
        end
      end
    end
  end
end
