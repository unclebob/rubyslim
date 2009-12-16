module TestModule
  class LibraryOld
    attr_reader :called
    def method_on_library_old
      @called = true;
    end

    def a_method
      @called = true
    end
  end
end