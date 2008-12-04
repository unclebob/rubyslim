require "slim_error"
require "statement"

class StatementExecutor
  def initialize
    @instances = {}
    @modules = []
  end

  def create(instance_name, class_name, constructor_arguments)
    begin
      @instances[instance_name] = construct_instance(class_name, constructor_arguments);
      "OK"
    rescue SlimError => e
      Statement::EXCEPTION_TAG + e.to_s
    end
  end

  def construct_instance(class_name, constructor_arguments)
    require_class(class_name);
    construct(class_name, constructor_arguments);
  end


  def make_path_to_class(class_name)
    module_names = split_class_name(class_name)
    files = module_names.collect { |module_name| to_file_name(module_name) }
    File.join(files)
  end

  def split_class_name(class_name)
    class_name.split(/\:\:/)
  end

  def construct(class_name, constructor_arguments)
    class_object = get_class(class_name)
    begin
      class_object.new(*constructor_arguments)
    rescue ArgumentError => e
      raise SlimError.new("message:<<COULD_NOT_INVOKE_CONSTRUCTOR #{class_name}[#{constructor_arguments.length}]>>")
    end
  end


  def with_each_fully_qualified_class_name(class_name, &block)
     (@modules.map{|module_name| module_name + "::" + class_name} << class_name).reverse.each &block
  end
  def require_class(class_name)
    with_each_fully_qualified_class_name(class_name) {|fully_qualified_name|
        begin
          require make_path_to_class(fully_qualified_name)
          return
        rescue LoadError
        end
      }
     raise SlimError.new("message:<<COULD_NOT_INVOKE_CONSTRUCTOR #{class_name} failed to find in #{@modules.map{|mod| make_path_to_class(mod)}.inspect}>>")
  end

  def get_class(class_name)
    with_each_fully_qualified_class_name(class_name) {|fully_qualified_name|
      begin
        return eval(fully_qualified_name)
      rescue NameError
      end
    }
    raise SlimError.new("message:<<COULD_NOT_INVOKE_CONSTRUCTOR #{class_name} in any module #{@modules.inspect}>>")
  end

  def instance(instance_name)
    @instances[instance_name]
  end

  def to_file_name(module_name)
    value = module_name[0..0].downcase + module_name[1..-1]
    value.gsub(/[A-Z]/) { |cap| "_#{cap.downcase}" }
  end

  def call(instance_name, method_name, *args)
    begin
      instance = @instances[instance_name]
      method = method_name.to_sym
      raise SlimError.new("message:<<NO_METHOD_IN_CLASS #{method}[#{args.length}] #{instance.class.name}.>>") if !instance.respond_to?(method)
      instance.send(method, *args)
    rescue SlimError => e
      Statement::EXCEPTION_TAG + e.to_s
    end
  end

  def add_module(module_name)
    @modules << module_name.gsub(/\./, '::')
  end


end