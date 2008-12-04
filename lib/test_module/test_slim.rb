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
  end 
end