require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require "list_serializer"

describe ListSerializer do
  it "can serialize and empty list" do
    ListSerializer.serialize([]).should == "[000000:]"
  end

  it "can serialize a one item list" do
    ListSerializer.serialize(["hello"]).should == "[000001:000005:hello:]"
  end

  it "can serialize a two item list" do
    ListSerializer.serialize(["hello", "world"]).should == "[000002:000005:hello:000005:world:]"
  end

  it "can serialize a nested list" do
    ListSerializer.serialize([["element"]]).should == "[000001:000024:[000001:000007:element:]:]" 
  end

  it "can serialize a list with a non-string" do
    ListSerializer.serialize([1]).should == "[000001:000001:1:]"
  end

  it "can serialize a null element" do
    ListSerializer.serialize([nil]).should == "[000001:000004:null:]"
  end
  
  it "can serialize a string with multibyte chars" do
    ListSerializer.serialize(["Köln"]).should == "[000001:000004:Köln:]"
  end

  it "can serialize a string with UTF8" do
    ListSerializer.serialize(["Español"]).should == "[000001:000007:Espa\xc3\xb1ol:]"
  end
  
  
end