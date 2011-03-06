require "rubyslim/socket_service"
require "rubyslim/list_deserializer"
require "rubyslim/list_serializer"
require "rubyslim/list_executor"

class RubySlim
  def run(port)
    @connected = true
    @executor = ListExecutor.new
    socket_service = SocketService.new()
    socket_service.serve(port) do |socket|
      serve_ruby_slim(socket)
    end

    while (@connected)
      sleep(0.1)
    end
  end

  # Read and execute instructions from the SliM socket, until a 'bye'
  # instruction is reached. Each instruction is a list, serialized as a string,
  # following the SliM protocol:
  #
  #   length:command
  #
  # Where `length` is a 6-digit indicating the length in bytes of `command`,
  # and `command` is a serialized list of instructions that may include any
  # of the four standard instructions in the SliM protocol:
  #
  #   Import: [<id>, import, <path>]
  #   Make: [<id>, make, <instance>, <class>, <arg>...]
  #   Call: [<id>, call, <instance>, <function>, <arg>...]
  #   CallAndAssign: [<id>, callAndAssign, <symbol>, <instance>, <function>, <arg>...]
  #
  # (from http://fitnesse.org/FitNesse.UserGuide.SliM.SlimProtocol)
  #
  def serve_ruby_slim(socket)
    socket.puts("Slim -- V0.3");
    said_bye = false

    while !said_bye
      length = socket.read(6).to_i   # <length>
      socket.read(1)                 # :
      command = socket.read(length)  # <command>

      # Until a 'bye' command is received, deserialize the command, execute the
      # instructions, and write a serialized response back to the socket.
      if command.downcase != "bye"
        instructions = ListDeserializer.deserialize(command);
        results = @executor.execute(instructions)
        response = ListSerializer.serialize(results);
        socket.write(sprintf("%06d:%s", response.length, response))
        socket.flush
      else
        said_bye = true
      end
    end
    @connected = false
  end
end

