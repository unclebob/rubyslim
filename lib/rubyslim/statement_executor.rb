require "rubyslim/slim_error"
require "rubyslim/statement"
require "rubyslim/table_to_hash_converter"
require "rubyslim/slim_helper_library"

class StatementExecutor
  def initialize
    @instances = {}
    @modules = []
    @symbols = {}
    @libraries = [SlimHelperLibrary.new(self)]
  end

  def library?(instance_name)
    library_prefix = "library"
    instance_name[0, library_prefix.length] == library_prefix
  end

  def create(instance_name, class_name, constructor_arguments)
    begin
      instance = replace_symbol(class_name)
      if instance.is_a?(String)
        instance = construct_instance(instance, replace_symbols(constructor_arguments))
        if library?(instance_name)
          @libraries << instance
        end
      end
      set_instance(instance_name, instance)
      "OK"
    rescue SlimError => e
      Statement::EXCEPTION_TAG + e.to_s
    end
  end

  def set_instance(instance_name, instance)
    @instances[instance_name] = instance
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
    (@modules.map { |module_name| module_name + "::" + class_name } << class_name).reverse.each &block
  end

  def require_class(class_name)
    with_each_fully_qualified_class_name(class_name) do |fully_qualified_name|
      begin
        require make_path_to_class(fully_qualified_name)
        return
      rescue LoadError
      end
    end
    raise SlimError.new("message:<<COULD_NOT_INVOKE_CONSTRUCTOR #{class_name} failed to find in #{@modules.map { |mod| make_path_to_class(mod) }.inspect}>>")
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
    symbols = replace_symbols(args)
    instance.send(method, *replace_tables_with_hashes(symbols))
  end

  def method_to_call(instance, method_name)
    return nil unless instance
    return method_name.to_sym if instance.respond_to?(method_name)
    return "#{$1}=".to_sym if method_name =~ /set_(\w+)/ && instance.respond_to?("#{$1}=")
    return nil
  end

  def call(instance_name, method_name, *args)
    begin
      instance = self.instance(instance_name)
      if method = method_to_call(instance, method_name)
        send_message_to_instance(instance, method, args)
      elsif instance.respond_to?(:sut) && method = method_to_call(instance.sut, method_name)
        send_message_to_instance(instance.sut, method, args)
      else
        @libraries.reverse_each do |library|
          method = method_to_call(library, method_name)
          return send_message_to_instance(library, method, args) if method
        end
        raise SlimError.new("message:<<NO_INSTANCE #{instance_name}>>") if instance.nil?
        raise SlimError.new("message:<<NO_METHOD_IN_CLASS #{method_name}[#{args.length}] #{instance.class.name}.>>")
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

  def acquire_symbol(symbol_text)
    symbol = get_symbol(symbol_text[1..-1])
    symbol = symbol_text if symbol.nil?
    symbol
  end

  def replace_symbol(item)
    match = item.match(/\A\$\w*\z/)
    return acquire_symbol(match[0]) if match

    item.gsub(/\$\w*/) do |match|
      acquire_symbol(match)
    end
  end

  def replace_symbols(list)
    list.map do |item|
      if item.kind_of?(Array)
        replace_symbols(item)
      else
        replace_symbol(item)
      end
    end
  end
end
