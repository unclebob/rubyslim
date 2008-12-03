require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require "statement"

describe Statement do
  before do
    @statement = Statement.new("")
  end

  it "should translate slim class names to ruby class names" do
    @statement.slim_to_ruby_class("myPackage.MyClass").should == "MyPackage::MyClass"
    @statement.slim_to_ruby_class("this.that::theOther").should == "This::That::TheOther"
  end

  it "should translate slim method names to ruby method names" do
    @statement.slim_to_ruby_method("myMethod").should == "my_method"
  end
end