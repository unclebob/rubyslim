require 'socket'
require 'thread'


class SocketService

  attr_reader :closed

  def initialize()
    @ropeSocket = nil
    @group = ThreadGroup.new
    @serviceThread = nil
  end

  def serve(port, &action)
    @closed = false
    @action = action
    @ropeSocket = TCPServer.open(port)
    @serviceThread = Thread.start {serviceTask}
    @group.add(@serviceThread)
  end

  def pendingSessions
    @group.list.size - ((@serviceThread != nil) ? 1 : 0)
  end

  def serviceTask
    while true
      Thread.start(@ropeSocket.accept) do |s|
        serverTask(s)
      end
    end
  end

  def serverTask(s)
    @action.call(s)
    s.close
  end

  def close
    @serviceThread.kill
    @serviceThread = nil
    @ropeSocket.close
    waitForServers
    @closed = true
  end

  def waitForServers
    @group.list.each do |t|
      t.join
    end
  end
end
