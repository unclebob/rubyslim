require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require "statement_executor"

describe StatementExecutor do
  before do
    @executor = StatementExecutor.new
  end
  context "Simple Method Invocations" do
    before do
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
      @test_slim.should_receive(:return_value).and_return("Español")
      val = @executor.call("test_slim", "return_value")
      val.should == "Español"
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

    it "should call attributes on sut" do
      @executor.call("test_slim", "set_attribute", "a")
      @executor.call("test_slim", "attribute").should == "a"
    end
  end

  context "Method invocations using fixture with no sut" do
    before do
      @executor.create("test_slim", "TestModule::TestSlimWithNoSut", []);
      @test_slim = @executor.instance("test_slim")
    end

    it "can't call method that doesn't exist if no 'sut' exists" do
      result = @executor.call("test_slim", "no_such_method")
      result.should include(Statement::EXCEPTION_TAG + "message:<<NO_METHOD_IN_CLASS no_such_method[0] TestModule::TestSlimWithNoSut.>>")
    end
  end

  context "Method invocations when library instances have been created." do
    before do
      @executor.create("library_old", "TestModule::LibraryOld", [])
      @executor.create("library_new", "TestModule::LibraryNew", [])
      @library_old = @executor.instance("library_old")
      @library_new = @executor.instance("library_new")
      @executor.create("test_slim", "TestModule::TestSlim", [])
      @test_slim = @executor.instance("test_slim")
    end

    it "should throw normal exception if no such method is found." do
      result = @executor.call("test_slim", "no_such_method")
      result.should include(Statement::EXCEPTION_TAG + "message:<<NO_METHOD_IN_CLASS no_such_method[0] TestModule::TestSlim.>>")
    end

    it "should still call normal methods in fixture" do
      @test_slim.should_receive(:no_args).with()
      @executor.call("test_slim", "no_args")
    end

    it "should still call methods on the sut" do
      @test_slim.sut.should_receive(:sut_method).with()
      @executor.call("test_slim", "sut_method")
    end

    it "should call a specific method on library_old" do
      @library_old.should_receive(:method_on_library_old).with()
      @executor.call("test_slim", "method_on_library_old")
    end

    it "should call a specific method on library_new" do
      @library_new.should_receive(:method_on_library_new).with()
      @executor.call("test_slim", "method_on_library_new")
    end

    it "should call method on library_new but not on library_old" do
      @library_new.should_receive(:a_method).with()
      @library_old.should_not_receive(:a_method).with()
      @executor.call("test_slim", "a_method")
    end

    it "should call built-in library methods" do
      @executor.call("test_slim", "push_fixture").should == nil
      @executor.call("test_slim", "pop_fixture").should == nil
    end

    it "should translate getters and setters" do
      @executor.call("test_slim", "set_lib_attribute", "lemon")
      @executor.call("test_slim", "lib_attribute").should == "lemon"
    end

  end
end