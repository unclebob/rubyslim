require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require "list_serializer"
require "list_deserializer"

describe ListDeserializer do
  before do
    @list = []
  end

  it "can't deserialize a null string" do
    proc {ListDeserializer.deserialize(nil)}.should raise_error(ListDeserializer::SyntaxError)
  end

  it "can't deserialize empty string" do
    proc {ListDeserializer.deserialize("")}.should raise_error(ListDeserializer::SyntaxError)
  end

  it "can't deserialize string that doesn't start with an open bracket" do
    proc {ListDeserializer.deserialize("hello")}.should raise_error(ListDeserializer::SyntaxError)
  end

  it "can't deserialize string that doesn't end with a bracket" do
    proc {ListDeserializer.deserialize("[000000:")}.should raise_error(ListDeserializer::SyntaxError)    
  end

  def check()
    serialized = ListSerializer.serialize(@list)
    deserialized = ListDeserializer.deserialize(serialized)
    deserialized.should == @list
  end

  it "can deserialize and empty list" do
    check
  end

  it "can deserialize a list with one element" do
    @list = ["hello"]
    check
  end

  it "can deserialize a list with two elements" do
    @list = ["hello", "bob"]
    check
  end  

  it "can deserialize sublists" do
    @list = ["hello", ["bob", "micah"], "today"]
    check
  end
  
  it "can deserialize lists with multibyte strings" do
    @list = ["Köln"]
    check
  end 
  
  it "can deserialize lists of strings that end with multibyte chars" do
    @list = ["Kö"]
    check
  end

  it "can deserialize lists with utf8" do
    @list = ["123456789012345", "Espa\357\277\275ol"]
    check
  end 

  it "should raise error when extended ascii charaters are used" do
    serialized ="[000002:000119:[000006:000015:scriptTable_3_0:000004:call:000016:scriptTableActor:000005:setTo:000015:System\\Language:000007:Espa\361ol:]:000033:[000002:000005:hello:000003:bob:]:]"    
    proc {Timeout::timeout(1.5){deserialized = ListDeserializer.deserialize(serialized)}.should_not raise_error(Timeout::Error)}.should raise_error(ListDeserializer::SyntaxError)
  end
  
end