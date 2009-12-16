module TestModule
  class SystemUnderTest
    def sut_method
      true
    end
  end

  class TestSlim
    attr_reader :sut
    def initialize
      @sut = SystemUnderTest.new
    end

    def return_string
      "string"
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

  end
end