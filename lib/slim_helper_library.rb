class SlimHelperLibrary
  ACTOR_INSTANCE_NAME = "scriptTableActor"
  attr_accessor :executor

  def initialize(executor = nil)
    @executor = executor
    @fixtures = []
  end

  def get_fixture
    executor.instance(ACTOR_INSTANCE_NAME)
  end

  def push_fixture
    @fixtures << get_fixture
    nil
  end

  def pop_fixture
    executor.set_instance(ACTOR_INSTANCE_NAME, @fixtures.pop)
    nil
  end
end