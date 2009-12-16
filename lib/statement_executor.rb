require "slim_error"
require "statement"
require "table_to_hash_converter"

class StatementExecutor
  def initialize
    @instances = {}
    @modules = []
    @symbols = {}
    @libraries = []
  end

  def library?(instance_name)
    library_prefix = "library"
    instance_name[0, library_prefix.length] == library_prefix
  end

  def create(instance_name, class_name, constructor_arguments)
    begin
      instance = construct_instance(class_name, replace_symbols(constructor_arguments))
      if library?(instance_name)
        @libraries << instance
      end
      @instances[instance_name] = instance
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

  def replace_tables_with_hashes(constructor_arguments)
    args = constructor_arguments.map do |arg|
      TableToHashConverter.convert arg
    end
    return args
  end

  def construct(class_name, constructor_arguments)
    class_object = get_class(class_name)
    begin
      class_object.new(*replace_tables_with_hashes(constructor_arguments))
    rescue ArgumentError => e
      raise SlimError.new("message:<<COULD_NOT_INVOKE_CONSTRUCTOR #{class_name}[#{constructor_arguments.length}]>>")
    end
  end


  def with_each_fully_qualified_class_name(class_name, &block)
    (@modules.map{|module_name| module_name + "::" + class_name} << class_name).reverse.each &block
  end

  def require_class(class_name)
    with_each_fully_qualified_class_name(class_name) do |fully_qualified_name|
      begin
        require make_path_to_class(fully_qualified_name)
        return
      rescue LoadError
      end
    end
    raise SlimError.new("message:<<COULD_NOT_INVOKE_CONSTRUCTOR #{class_name} failed to find in #{@modules.map{|mod| make_path_to_class(mod)}.inspect}>>")
  end

  def get_class(class_name)
    with_each_fully_qualified_class_name(class_name) do |fully_qualified_name|
      begin
        return eval(fully_qualified_name)
      rescue NameError
      end
    end
    raise SlimError.new("message:<<COULD_NOT_INVOKE_CONSTRUCTOR #{class_name} in any module #{@modules.inspect}>>")
  end

  def instance(instance_name)
    @instances[instance_name]
  end

  def to_file_name(module_name)
    value = module_name[0..0].downcase + module_name[1..-1]
    value.gsub(/[A-Z]/) { |cap| "_#{cap.downcase}" }
  end

  def send_message_to_instance(instance, method, args)
    instance.send(method, *replace_tables_with_hashes(replace_symbols(args)))
  end

  def call(instance_name, method_name, *args)
    begin
      instance = @instances[instance_name]
      method = method_name.to_sym
      if instance && instance.respond_to?(method)
        send_message_to_instance(instance, method, args)
      elsif instance.respond_to?(:sut) && instance.sut.respond_to?(method)
        send_message_to_instance(instance.sut, method, args)
      else
        @libraries.reverse_each do |library|
          return send_message_to_instance(library, method, args) if (library.respond_to?(method))
        end
        raise SlimError.new("message:<<NO_INSTANCE #{instance_name}>>") if instance.nil?        
        raise SlimError.new("message:<<NO_METHOD_IN_CLASS #{method}[#{args.length}] #{instance.class.name}.>>")
      end
    rescue SlimError => e
      Statement::EXCEPTION_TAG + e.to_s
    end
  end

  def add_module(module_name)
    @modules << module_name.gsub(/\./, '::')
  end

  def set_symbol(name, value)
    @symbols[name] = value
  end

  def get_symbol(name)
    @symbols[name]
  end

  def replace_symbols(list)
    list.map do |item|
      if item.kind_of?(Array)
        replace_symbols(item)
      else
        item.gsub(/\$\w*/) do |match|
          symbol = get_symbol(match[1..-1])
          symbol = match if symbol.nil?
          symbol
        end
      end
    end
  end
end