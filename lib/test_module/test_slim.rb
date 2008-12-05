module TestModule
  class TestSlim
    def return_string
      "string"
    end

    def returnString  #Should not ever be called.
      "blah"
    end

    def add(a,b)
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
  end 
end