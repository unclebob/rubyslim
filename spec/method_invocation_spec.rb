require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require "statement_executor"

describe StatementExecutor do
  before do
    @executor = StatementExecutor.new
    @executor.create("test_slim", "TestModule::TestSlim", [])
    @test_slim = @executor.instance("test_slim")
  end

  it "can call a method with no arguments" do
    @test_slim.should_receive(:no_args).with()
    @executor.call("test_slim", "no_args")
  end

  it "can't call a method that doesn't exist" do
    result = @executor.call("test_slim", "no_such_method")
    result.should include(Statement::EXCEPTION_TAG + "message:<<NO_METHOD_IN_CLASS no_such_method[0] TestModule::TestSlim.>>")
  end

  it "can call a method that returns a value" do
    @test_slim.should_receive(:return_value).and_return("arg")
    @executor.call("test_slim", "return_value").should == "arg"
  end

  it "can call a method that returns a value" do
    @test_slim.should_receive(:return_value).and_return("Espa\357\277\275ol")
    val = @executor.call("test_slim", "return_value")
    val.should == "Espa\357\277\275ol"
    val.jlength.should == 7
  end


  it "can call a method that takes an argument" do
    @test_slim.should_receive(:one_arg).with("arg")
    @executor.call("test_slim", "one_arg", "arg")
  end

  it "can't call a method on an instance that doesn't exist" do
    result = @executor.call("no_such_instance", "no_such_method")
    result.should include(Statement::EXCEPTION_TAG + "message:<<NO_INSTANCE no_such_instance>>")
  end

  it "can replace symbol expressions with their values" do
    @executor.set_symbol("v", "bob")
    @executor.call("test_slim", "echo", "hi $v.").should == "hi bob."
  end

  it "can call a method on the @sut" do
    @test_slim.sut.should_receive(:sut_method).with()
    @executor.call("test_slim", "sut_method")
  end

  it "can't call method that doesn't exist if no 'sut' exists" do
    @executor.create("test_slim", "TestModule::TestSlimWithNoSut", []);
    @test_slim = @executor.instance("test_slim")
    result = @executor.call("test_slim", "no_such_method")
    result.should include(Statement::EXCEPTION_TAG + "message:<<NO_METHOD_IN_CLASS no_such_method[0] TestModule::TestSlimWithNoSut.>>")    
  end
end