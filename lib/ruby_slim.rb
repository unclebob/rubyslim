require "socket_service"
require "list_deserializer"
require "list_serializer"
require "list_executor"

class RubySlim
  def run(port)
    @connected = true
    @executor = ListExecutor.new
    socket_service = SocketService.new()
    socket_service.serve(port) do  |socket|
      serve_ruby_slim(socket)
    end

    while (@connected)
      sleep(0.1)
    end
  end

  def serve_ruby_slim(socket)
    socket.puts("Slim -- V0.1");
    said_bye = false
    while !said_bye
      length = socket.read(6).to_i
      socket.read(1); #skip colon
      command = socket.read(length);
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

