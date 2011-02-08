require 'ostruct'

module TestModule
  class SystemUnderTest
    attr_accessor :attribute
    def sut_method
      true
    end
  end

  class TestSlim
    attr_reader :sut
    attr_accessor :string

    def initialize(generation = 0)
      @generation = generation
      @sut = SystemUnderTest.new
      @string = "string"
    end

    def return_string
      @string
    end

    def returnString  #Should not ever be called.
      "blah"
    end

    def add(a, b)
      a+b
    end

    def echo(x)
      x
    end

    def null
      nil
    end

    def echo_int i
      i
    end

    def echo_string s
      s
    end

    def syntax_error
      eval "1,2"
    end

    def utf8
      "Espa\357\277\275ol"
    end

    def create_test_slim_with_string(string)
      slim = TestSlim.new(@generation + 1)
      slim.string = string
      slim
    end

    def new_with_string(string)
      s = TestSlim.new
      s.string = string
      s
    end

    def echo_object(method, string)
      OpenStruct.new(method.to_sym => string)
    end

    def call_on(method, object)
      object.send(method.to_sym)
    end

#    def is_same(other)
#      self === other
#    end
#
#    def  get_string_from_other other
#      other.get_string_arg
#    end

  end
end