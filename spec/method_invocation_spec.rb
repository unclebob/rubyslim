require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require "statement_executor"

describe StatementExecutor do
  before do
    @caller = StatementExecutor.new
    @caller.create("test_slim", "TestModule::TestSlim", [])
    @test_slim = @caller.instance("test_slim")
  end

  it "can call a method with no arguments" do
    @test_slim.should_receive(:no_args).with()
    @caller.call("test_slim", "no_args")
  end

  it "can't call a method that doesn't exist" do
    begin
      @caller.call("test_slim", "no_such_method")
      fail("Shouldn't get here");
    rescue SlimError => e
      e.to_s.should == "message:<<NO_METHOD_IN_CLASS no_such_method[0] TestModule::TestSlim.>>"
    end
  end

  it "can call a method that returns a value" do
    @test_slim.should_receive(:return_value).and_return("arg")
    @caller.call("test_slim", "return_value").should == "arg"
  end

  it "can call a method that takes an argument" do
    @test_slim.should_receive(:one_arg).with("arg")
    @caller.call("test_slim", "one_arg", "arg")
  end

  it "can't call a method on an instance that doesn't exist" do
    proc {@caller.call("no_such_instance", "no_such_method")}.should raise_error(SlimError)
  end
end