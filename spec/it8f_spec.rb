require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "characters" do
  it "should be able to deal with it8f chars" do
    "Köln".should == "Köln"
    "Köln".size.should == 5
  end
end