require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require "statement_executor"
require "list_executor"

describe ListExecutor do
  before do
    @executor = ListExecutor.new
    @statements = []
    @statements << ["i1", "import", "TestModule"]
    @statements << ["m1", "make", "test_slim", "TestSlim"]
    @expected_results = []
    @expected_results << ["i1", "OK"]
    @expected_results << ["m1", "OK"]
  end

  it "can't execute an invalid operation" do
    @statements << ["inv1", "invalidOperation"]
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
    @statements << ["id", "call", "notEnoughArguments"]
    message = "message:<<MALFORMED_INSTRUCTION [\"id\", \"call\", \"notEnoughArguments\"].>>"
    proc {@executor.execute(@statements)}.should raise_error(SlimError, message)
  end

  it "can't call a method on an instance that doesn't exist" do
    @statements << ["id", "call", "no_such_instance", "no_such_method"]
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
    @statements << ["id", "call", "test_slim", "return_string"]
    results = @executor.execute(@statements)
    get_result("m1", results).should == "OK"
    get_result("id", results).should == "string"
  end

  it "can call a simple method in FitNesse form" do
    @statements << ["id", "call", "test_slim", "returnString"]
    results = @executor.execute(@statements)
    get_result("m1", results).should == "OK"
    get_result("id", results).should == "string"
  end

  it "will allow later imports to take precendence over early imports" do
    @statements.insert(0, ["i2", "import", "TestModule.ShouldNotFindTestSlimInHere"])
    @statements << ["id", "call", "test_slim", "return_string"]
    results = @executor.execute(@statements)
    get_result("m1", results).should == "OK"
    get_result("id", results).should == "string"
  end
end