module TestModule
  class LibraryNew
    attr_reader :called
    attr_accessor :lib_attribute
    def method_on_library_new
      @called = true;
    end

    def a_method
      @called = true;
    end
  end
end