require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require 'slim_helper_library'
require 'statement_executor'

SLIM_HELPER_LIBRARY_INSTANCE_NAME = "SlimHelperLibrary"
ACTOR_INSTANCE_NAME = "scriptTableActor"

describe SlimHelperLibrary do
  before() do
    @executor = StatementExecutor.new
    @executor.add_module("TestModule")
    @executor.create(ACTOR_INSTANCE_NAME, "TestSlim", ["0"]).should == "OK"
    @instance = @executor.instance(ACTOR_INSTANCE_NAME)
    @helper = SlimHelperLibrary.new(@executor)
  end

  it "can get current scriptTableActor" do
    @helper.get_fixture.should be @instance
  end

  it "can push and pop" do
    @helper.push_fixture
    @executor.create(ACTOR_INSTANCE_NAME, "TestSlim", ["1"])
    @helper.get_fixture.should_not be @instance
    @helper.pop_fixture
    @helper.get_fixture.should be @instance
  end

  it "can push and pop many" do
    @helper.push_fixture
    @executor.create(ACTOR_INSTANCE_NAME, "TestChain", []).should == "OK"
    one = @executor.instance(ACTOR_INSTANCE_NAME)
    one.should_not be_nil
    @helper.push_fixture

    @executor.create(ACTOR_INSTANCE_NAME, "SimpleScript", [])
    two = @executor.instance(ACTOR_INSTANCE_NAME)
    one.should_not be two
    @helper.get_fixture.should be two

    @helper.pop_fixture
    @helper.get_fixture.should be one

    @helper.pop_fixture
    @helper.get_fixture.should be @instance

  end

end


#@Test
#public void testSlimHelperLibraryIsStoredInSlimExecutor() throws Exception {
#  Object helperLibrary = caller.getInstance(SLIM_HELPER_LIBRARY_INSTANCE_NAME);
#  assertTrue(helperLibrary instanceof SlimHelperLibrary);
#}
#
#@Test
#public void testSlimHelperLibraryHasStatementExecutor() throws Exception {
#  SlimHelperLibrary helperLibrary = (SlimHelperLibrary) caller.getInstance(SLIM_HELPER_LIBRARY_INSTANCE_NAME);
#  assertSame(caller, helperLibrary.getStatementExecutor());
#}
#
#@Test
#public void testSlimHelperLibraryCanPushAndPopFixture() throws Exception {
#  SlimHelperLibrary helperLibrary = (SlimHelperLibrary) caller.getInstance(SLIM_HELPER_LIBRARY_INSTANCE_NAME);
#  Object response = caller.create(ACTOR_INSTANCE_NAME, getTestClassName(), new Object[0]);
#  Object firstActor = caller.getInstance(ACTOR_INSTANCE_NAME);
#
#  helperLibrary.pushFixture();
#
#  response = caller.create(ACTOR_INSTANCE_NAME, getTestClassName(), new Object[] {"1"});
#  assertEquals("OK", response);
#  assertNotSame(firstActor, caller.getInstance(ACTOR_INSTANCE_NAME));
#
#  helperLibrary.popFixture();
#
#  assertSame(firstActor, caller.getInstance(ACTOR_INSTANCE_NAME));
#}
#
