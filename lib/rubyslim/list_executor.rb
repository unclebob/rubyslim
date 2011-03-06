require "statement"
require "statement_executor"

class ListExecutor
  def initialize()
    @executor = StatementExecutor.new
  end

  def execute(instructions)
    instructions.collect {|instruction| Statement.execute(instruction, @executor)}
  end
end
