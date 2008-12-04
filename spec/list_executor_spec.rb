require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require "statement_executor"
require "list_executor"

describe ListExecutor do
  before do
    @executor = ListExecutor.new
    @statements = []
    add_statement "i1", "import", "TestModule"
    add_statement "m1", "make", "test_slim", "TestSlim"
    @expected_results = []
    @expected_results << ["i1", "OK"]
    @expected_results << ["m1", "OK"]
  end

  it "can't execute an invalid operation" do
    add_statement "inv1", "invalidOperation"
    results = @executor.execute(@statements)
    get_result("inv1", results).should include(Statement::EXCEPTION_TAG+"message:<<INVALID_STATEMENT: [\"inv1\", \"invalidOperation\"].")
  end

  def get_result(id, result_list)
    pairs_to_map(result_list)[id]
  end

  def pairs_to_map(pairs)
    map = {}
    pairs.each {|pair| map[pair[0]] = pair[1]}
    map
  end

  it "can't execute a malformed instruction" do
    add_statement "id", "call", "notEnoughArguments"
    message = "message:<<MALFORMED_INSTRUCTION [\"id\", \"call\", \"notEnoughArguments\"].>>"
    proc {@executor.execute(@statements)}.should raise_error(SlimError, message)
  end

  it "can't call a method on an instance that doesn't exist" do
    add_statement "id", "call", "no_such_instance", "no_such_method"
    results = @executor.execute(@statements)
    get_result("id", results).should include(Statement::EXCEPTION_TAG+"message:<<NO_METHOD_IN_CLASS no_such_method[0] NilClass.>>")
  end

  it "should respond to an empty set of instructions with an empty set of results" do
    @executor.execute([]).length.should == 0
  end

  it "can make an instance given a fully qualified name in dot format" do
    @executor.execute([["m1", "make", "instance", "testModule.TestSlim"]]).should == [["m1", "OK"]]
  end

  it "can call a simple method in ruby form" do
    add_statement "id", "call", "test_slim", "return_string"
    results = @executor.execute(@statements)
    get_result("m1", results).should == "OK"
    get_result("id", results).should == "string"
  end

  it "can call a simple method in FitNesse form" do
    add_statement "id", "call", "test_slim", "returnString"
    results = @executor.execute(@statements)
    get_result("m1", results).should == "OK"
    get_result("id", results).should == "string"
  end

  it "will allow later imports to take precendence over early imports" do
    @statements.insert(0, ["i2", "import", "TestModule.ShouldNotFindTestSlimInHere"])
    add_statement "id", "call", "test_slim", "return_string"
    results = @executor.execute(@statements)
    get_result("m1", results).should == "OK"
    get_result("id", results).should == "string"
  end

  it "can pass arguments to constructor" do
    add_statement "m2", "make", "test_slim_2", "TestSlimWithArguments", "3"
    add_statement "c1", "call", "test_slim_2", "arg"
    results = @executor.execute(@statements)
    get_result("m2", results).should == "OK"
    get_result("c1", results).should == "3"
  end

  it "can call a function more than once" do
    add_statement "c1", "call", "test_slim", "add", "x", "y"
    add_statement "c2", "call", "test_slim", "add", "a", "b"
    results = @executor.execute(@statements)
    get_result("c1", results).should == "xy"
    get_result("c2", results).should == "ab"
  end

  it "can assign the return value to a symbol" do
    add_statement "id1", "callAndAssign", "v", "test_slim", "add", "x", "y"
    add_statement "id2", "call", "test_slim", "echo", "$v"
    results = @executor.execute(@statements)

    get_result("id1", results).should == "xy"
    get_result("id2", results).should == "xy"
  end

  def add_statement(*args)
    @statements << args
  end

end