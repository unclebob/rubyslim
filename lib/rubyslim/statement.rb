require "rubyslim/statement_executor"

class Statement
  EXCEPTION_TAG = "__EXCEPTION__:"
  def self.execute(statement, executor)
    Statement.new(statement).exec(executor)
  end

  def initialize(statement)
    @statement = statement
  end

  def exec(executor)
    @executor = executor
    begin
      case(operation)
      when "make"
        instance_name = get_word(2)
        class_name = slim_to_ruby_class(get_word(3))
        [id, @executor.create(instance_name, class_name, get_args(4))]
      when "import"
        @executor.add_module(slim_to_ruby_class(get_word(2)))
        [id, "OK"]
      when  "call"
        call_method_at_index(2)
      when "callAndAssign"
        result = call_method_at_index(3)
        @executor.set_symbol(get_word(2), result[1])
        result
      else
        [id, EXCEPTION_TAG + "message:<<INVALID_STATEMENT: #{@statement.inspect}.>>"]
      end
    rescue SlimError => e
      [id, EXCEPTION_TAG + e.message]
    rescue Exception => e
      [id, EXCEPTION_TAG + e.message + "\n" + e.backtrace.join("\n")]
    end

  end

  def call_method_at_index(index)
    instance_name = get_word(index)
    method_name = slim_to_ruby_method(get_word(index+1))
    args = get_args(index+2)
    [id, @executor.call(instance_name, method_name, *args)]
  end

  def slim_to_ruby_class(class_name)
    parts = class_name.split(/\.|\:\:/)
    converted = parts.collect {|part| part[0..0].upcase+part[1..-1]}
    converted.join("::")
  end

  def slim_to_ruby_method(method_name)
    value = method_name[0..0].downcase + method_name[1..-1]
    value.gsub(/[A-Z]/) { |cap| "_#{cap.downcase}" }
  end

  def id
    get_word(0)
  end

  def operation
    get_word(1)
  end

  def get_word(index)
    check_index(index)
    @statement[index]
  end

  def get_args(index)
    @statement[index..-1]
  end

  def check_index(index)
    raise SlimError.new("message:<<MALFORMED_INSTRUCTION #{@statement.inspect}.>>") if index >= @statement.length
  end
end
