require 'holepicker/logger'
require 'spec_helper'
require 'stringio'

describe HolePicker::Logger do
  let(:io) { StringIO.new }

  subject { HolePicker::Logger.new(io) }

  context "after initialization" do
    its(:level) { should == Logger::INFO }
  end

  describe "#print" do
    it "should log a message without a newline" do
      subject.print 'xxx'

      io.string.should == 'xxx'
    end

    context "if logger level is WARN or higher" do
      before { subject.level = Logger::WARN }

      it "should not log anything" do
        subject.print 'xxx'

        io.string.should be_empty
      end
    end
  end

  describe "#success" do
    it "should log a message in green" do
      subject.success 'aaa'

      io.string.should == "aaa".color(:green) + "\n"
    end

    context "if logger level is WARN or higher" do
      before { subject.level = Logger::WARN }

      it "should not log anything" do
        subject.success 'aaa'

        io.string.should be_empty
      end
    end
  end

  describe "#fail" do
    it "should log a message in red" do
      subject.fail 'rrr'

      io.string.should == "rrr".color(:red) + "\n"
    end

    context "if logger level is ERROR" do
      before { subject.level = Logger::ERROR }

      it "should still log the message" do
        subject.fail 'rrr'

        io.string.should == "rrr".color(:red) + "\n"
      end
    end
  end
end

describe HolePicker::HasLogger do
  class Foo
    include HolePicker::HasLogger
  end

  context "when included" do
    it "should add an instance method #logger" do
      Foo.new.logger.should == HolePicker.logger
    end

    it "should add a class method #logger" do
      Foo.logger.should == HolePicker.logger
    end
  end
end

describe "HolePicker.logger" do
  subject { HolePicker.logger }

  it { should be_a(HolePicker::Logger) }
end
