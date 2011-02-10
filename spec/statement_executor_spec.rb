require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require "statement_executor"

describe StatementExecutor do
  before do
    @executor = StatementExecutor.new
  end

  it "can split class names" do
    @executor.split_class_name("a::b::c").should == ["a", "b", "c"]
  end

  it "can convert module names to file names" do
    @executor.to_file_name("MyModuleName").should == "my_module_name"
  end

  it "can build the path name to a class" do
    @executor.make_path_to_class("ModuleOne::ModuleTwo::MyClass").should == "module_one/module_two/my_class"
  end

  it "can require a class" do
    @executor.add_module("MyModule")
    proc = proc {@executor.require_class("MyModule::MyClass")}
    proc.should raise_error(SlimError, /message:<<COULD_NOT_INVOKE_CONSTRUCTOR MyModule::MyClass failed to find in/)
  end

  it "can handle symbols whose values are objects" do
    @executor.set_symbol("foo", OpenStruct.new(:foo => "bar"))
    @executor.get_symbol("foo").foo.should == "bar"
    @executor.replace_symbol("$foo").foo.should == "bar"
  end

  describe "accessor translation" do
    class TestInstance
      attr_accessor :foo
    end

    before(:each) do
      @instance = TestInstance.new
      @executor.set_instance("test_instance", @instance)
    end

    it "should translate setters" do
      @executor.call("test_instance", "set_foo", "123")
      @instance.foo.should == "123"
    end

  end

end