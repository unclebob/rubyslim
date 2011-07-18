require "rubyslim/statement"
require "rubyslim/statement_executor"

class ListExecutor
  def initialize()
    @executor = StatementExecutor.new
  end

  def execute(instructions)
    instructions.collect {|instruction| Statement.execute(instruction, @executor)}
  end
end
