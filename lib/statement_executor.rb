require "slim_error"

class StatementExecutor
  def initialize
    @instances = {}
  end

  def create(instance_name, class_name, constructor_arguments)
    @instances[instance_name] = construct_instance(class_name, constructor_arguments);
    "OK"
  end

  def construct_instance(class_name, constructor_arguments)
    require_class(class_name);
    construct(class_name, constructor_arguments);
  end

  def require_class(class_name)
    path = make_path_to_class(class_name)
    begin
      require path
    rescue LoadError => e
      raise SlimError.new("message:<<COULD_NOT_INVOKE_CONSTRUCTOR #{path}>>")

    end
  end

  def make_path_to_class(class_name)
    module_names = split_class_name(class_name)
    files = module_names.collect { |module_name| to_file_name(module_name) }
    File.join(files)
  end

  def split_class_name(class_name)
    class_name.split(/\.|\:\:/)
  end

  def construct(class_name, constructor_arguments)
    module_path  = make_module_path(class_name)
    class_object = eval(module_path)
    begin
      class_object.new(*constructor_arguments)
    rescue ArgumentError => e
      raise SlimError.new("message:<<COULD_NOT_INVOKE_CONSTRUCTOR #{module_path}[#{constructor_arguments.length}]>>")
    end
  end

  def make_module_path(class_name)
    module_names = split_class_name(class_name)
    module_names.join("::");
  end

  def instance(instance_name)
    @instances[instance_name]
  end

  def to_file_name(module_name)
    value = module_name[0..0].downcase + module_name[1..-1]
    value.gsub(/[A-Z]/) { |cap| "_#{cap.downcase}" }
  end

  def call(instance_name, method_name, *args)
    instance = @instances[instance_name]
    method = method_name.to_sym
    raise SlimError.new("message:<<NO_METHOD_IN_CLASS #{method}[#{args.length}] #{instance.class.name}.>>") if !instance.respond_to?(method)
    instance.send(method, *args)
  end

  
end