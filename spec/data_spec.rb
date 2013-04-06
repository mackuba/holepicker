require 'spec_helper'

describe "data.json" do
  before { FakeFS.deactivate! }

  it "should contain proper JSON" do
    data = File.read('lib/holepicker/data/data.json')
    expect { JSON.parse(data) }.not_to raise_error
  end

  after { FakeFS.activate! }
end
