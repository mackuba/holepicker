require 'holepicker/utils'
require 'spec_helper'

describe HolePicker::Utils do
  let(:utils) { HolePicker::Utils }

  describe "#pluralize" do
    context "if count is more than 1" do
      it "should add 's' at the end" do
        utils.pluralize(2, 'bug').should == 'bugs'
      end

      context "if the word ends with 'y'" do
        it "should change use the '-ies' suffix" do
          utils.pluralize(3, 'copy').should == 'copies'
        end
      end
    end

    context "if count is 1" do
      it "should not add 's'" do
        utils.pluralize(1, 'bug').should == 'bug'
      end
    end

    context "if count is 0" do
      it "should add 's'" do
        utils.pluralize(0, 'bug').should == 'bugs'
      end
    end
  end
end
