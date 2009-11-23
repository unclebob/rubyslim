module TestModule
  class TestSlimWithArguments
    def initialize(arg)
      @arg = arg
    end

    def arg
      @arg
    end

    def name
      @arg[:name]
    end

    def addr
      @arg[:addr]
    end

    def set_arg(hash)
      @arg = hash
    end
  end
end