require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require "statement_executor"

describe StatementExecutor do
  before do
    @executor = StatementExecutor.new
  end

  it "should split class names with dots" do
    @executor.split_class_name("a.b.c").should == ["a", "b", "c"]
    @executor.split_class_name("a::b::c").should == ["a", "b", "c"]
  end

  it "should convert module names to file names" do
    @executor.to_file_name("MyModuleName").should == "my_module_name"
  end

  it "should build the path name to a class" do
    @executor.make_path_to_class("ModuleOne::ModuleTwo.MyClass").should == "module_one/module_two/my_class"
  end

  it "should require a class" do
      proc = proc {@executor.require_class("MyModule::MyClass")}
      proc.should raise_error(SlimError, "message:<<COULD_NOT_INVOKE_CONSTRUCTOR my_module/my_class>>")
  end

  it "should build a fully qualified class name" do
    @executor.make_module_path("MyModule.MyClass").should == "MyModule::MyClass"
  end
end