require File.expand_path(File.dirname(__FILE__) + "/init")
require "socket_service"

connected = true
port = ARGV[0].to_i
puts "port: #{port}"
socket_service = SocketService.new()
socket_service.serve(port) do  |socket|
puts "Got connection"  
  socket.puts("Slim -- V0.0");
  length = socket.read(6).to_i
  socket.read(1); #skip colon
  command = socket.read(length);
  if command.downcase != "bye"
    puts "Oh no, that wasn't a bye."
  end
  connected = false
end

while connected
  sleep(0.1)
end

