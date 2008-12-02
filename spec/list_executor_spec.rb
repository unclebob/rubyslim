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
    result_map = pairs_to_map(results)
    result = result_map["inv1"]
    result.should include("__EXCEPTION__:")  
  end

  def pairs_to_map(pairs)
    map = {}
    pairs.each {|pair| map[pair[0]] = pair[1]}
    map
  end
end