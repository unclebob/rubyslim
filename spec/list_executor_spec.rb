require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require "statement_executor"
require "list_executor"

describe ListExecutor do
  before do
    @executor = ListExecutor.new
    @statements = []
    @table = "<table><tr><td>name</td><td>bob</td></tr><tr><td>addr</td><td>here</td></tr></table>"
    add_statement "i1", "import", "TestModule"
    add_statement "m1", "make", "test_slim", "TestSlim"
  end

  def get_result(id, result_list)
    pairs_to_map(result_list)[id]
  end

  def pairs_to_map(pairs)
    map = {}
    pairs.each {|pair| map[pair[0]] = pair[1]}
    map
  end

  def add_statement(*args)
    @statements << args
  end

  def check_results expectations
    results = @executor.execute(@statements)
    expectations.each_pair {|id, expected|
      get_result(id, results).should == expected
    }
  end

  it "can respond with OK to import" do
    check_results "i1"=>"OK"
  end

  it "can't execute an invalid operation" do
    add_statement "inv1", "invalidOperation"
    results = @executor.execute(@statements)
    get_result("inv1", results).should include(Statement::EXCEPTION_TAG+"message:<<INVALID_STATEMENT: [\"inv1\", \"invalidOperation\"].")
  end

  it "can't execute a malformed instruction" do
    add_statement "id", "call", "notEnoughArguments"
    message = "message:<<MALFORMED_INSTRUCTION [\"id\", \"call\", \"notEnoughArguments\"].>>"
    results = @executor.execute(@statements)
    get_result("id", results).should include(Statement::EXCEPTION_TAG+message)
  end

  it "can't call a method on an instance that doesn't exist" do
    add_statement "id", "call", "no_such_instance", "no_such_method"
    results = @executor.execute(@statements)
    get_result("id", results).should include(Statement::EXCEPTION_TAG+"message:<<NO_INSTANCE no_such_instance>>")
  end

  it "should respond to an empty set of instructions with an empty set of results" do
    @executor.execute([]).length.should == 0
  end

  it "can make an instance given a fully qualified name in dot format" do
    @executor.execute([["m1", "make", "instance", "testModule.TestSlim"]]).should == [["m1", "OK"]]
  end

  it "can call a simple method in ruby form" do
    add_statement "id", "call", "test_slim", "return_string"

    check_results "m1" => "OK", "id"=>"string"
  end

  it "can call a simple method in ruby form" do
    add_statement "id", "call", "test_slim", "utf8"

    check_results "m1" => "OK", "id"=>"Espa\357\277\275ol"
  end


  it "can call a simple method in FitNesse form" do
    add_statement "id", "call", "test_slim", "returnString"

    check_results "m1"=>"OK", "id"=>"string"
  end

  it "will allow later imports to take precendence over early imports" do
    @statements.insert(0, ["i2", "import", "TestModule.ShouldNotFindTestSlimInHere"])
    add_statement "id", "call", "test_slim", "return_string"
    check_results "m1"=>"OK", "id"=>"string"
  end

  it "can pass arguments to constructor" do
    add_statement "m2", "make", "test_slim_2", "TestSlimWithArguments", "3"
    add_statement "c1", "call", "test_slim_2", "arg"

    check_results "m2"=>"OK", "c1"=>"3"
  end

  it "can pass tables to constructor" do
    add_statement "m2", "make", "test_slim_2", "TestSlimWithArguments", @table
    add_statement "c1", "call", "test_slim_2", "name"
    add_statement "c2", "call", "test_slim_2", "addr"

    check_results "m2"=>"OK", "c1"=>"bob", "c2"=>"here"
  end

  it "can pass tables to functions" do
    add_statement "m2", "make", "test_slim_2", "TestSlimWithArguments", "nil"    
    add_statement "c0", "call", "test_slim_2", "set_arg", @table
    add_statement "c1", "call", "test_slim_2", "name"
    add_statement "c2", "call", "test_slim_2", "addr"

    check_results "m2"=>"OK", "c1"=>"bob", "c2"=>"here"
  end

  it "can call a function more than once" do
    add_statement "c1", "call", "test_slim", "add", "x", "y"
    add_statement "c2", "call", "test_slim", "add", "a", "b"

    check_results "c1" => "xy", "c2" => "ab"
  end

  it "can assign the return value to a symbol" do
    add_statement "id1", "callAndAssign", "v", "test_slim", "add", "x", "y"
    add_statement "id2", "call", "test_slim", "echo", "$v"
    check_results "id1" => "xy", "id2" => "xy"
  end

  it "can replace multiple symbols in a single argument" do
    add_statement "id1", "callAndAssign", "v1", "test_slim", "echo", "Bob"
    add_statement "id2", "callAndAssign", "v2", "test_slim", "echo", "Martin"
    add_statement "id3", "call", "test_slim", "echo", "name: $v1 $v2"
    check_results "id3" => "name: Bob Martin"
  end

  it "should ignore '$' if what follows is not a symbol" do
    add_statement "id3", "call", "test_slim", "echo", "$v1"
    check_results "id3" => "$v1"
  end

  it "can pass and return a list" do
    l = ["1", "2"]
    add_statement "id", "call", "test_slim", "echo", l
    check_results "id"=> l
  end

  it "can pass a symbol in a list" do
    add_statement "id1", "callAndAssign", "v", "test_slim", "echo", "x"
    add_statement "id2", "call", "test_slim", "echo", ["$v"]
    check_results "id2" => ["x"]
  end

  it "can return null" do
    add_statement "id", "call", "test_slim", "null"
    check_results "id" => nil
  end

  it "can survive executing a syntax error" do
    add_statement "id", "call", "test_slim", "syntax_error"
    results = @executor.execute(@statements)
    get_result("id", results).should include(Statement::EXCEPTION_TAG)
  end

  it "can make a fixture from the name in a symbol" do
    add_statement "id1", "callAndAssign", "test_system", "test_slim", "echo", "TestChain"
    add_statement "id2", "make", "fixture_instance1", "$test_system"
    check_results "id2"=>"OK"
  end

  it "can make a fixture from a concatonated symbol" do
    add_statement "id1", "callAndAssign", "test_system", "test_slim", "echo", "Chain"
    add_statement "id2", "make", "fixture_instance1", "Test$test_system"
    check_results "id2"=>"OK"
  end

  it "can use a fixture method that returns a fixture object" do
    add_statement "id1", "callAndAssign", "object", "test_slim", "echo_object", "let_me_see", "Boogaloo"
    add_statement "id2", "call", "test_slim", "call_on", "let_me_see", "$object"
    check_results "id2" => "Boogaloo"
  end

  it "can use an instance that was stored as a symbol" do
    add_statement "id1", "callAndAssign", "test_slim_instance", "test_slim", "create_test_slim_with_string", "Boogaloo"
    add_statement "m2", "make", "test_slim", "$test_slim_instance"
    check_results "m2" => "OK"
  end

end