require 'test/unit'
require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require 'socket_service'

class SocketServiceTest < Test::Unit::TestCase
  def setup
  	@port = 12345
    @ss = SocketService.new()
    @connections = 0
  end

  def testOneConnection
    @ss.serve(@port) {@connections += 1}
    connect(@port)
    @ss.close()
    assert_equal(1, @connections)
  end

  def testManyConnections
    @ss.serve(@port) {@connections += 1}
    10.times {connect(@port)}
    @ss.close()
    assert_equal(10, @connections)
    assert_equal(0, @ss.pendingSessions)
  end

  def testSocketSend
    @ss.serve(@port) do |serverSocket|
      serverSocket.write("hi")
    end

    clientSocket = TCPSocket.open("localhost", @port)
    answer = clientSocket.gets
    clientSocket.close
    assert_equal("hi", answer)
    @ss.close()
  end

  # TEST FREEZES!!!
  # We should not be able to keep the service alive by hitting
  # it with connections after we close it?
  def _testCantKeepAliveByConnectingAfterClose
    #set up a service that waits for a message and then dies.
    @ss.serve(@port) do |serverSocket|
      message = serverSocket.gets
    end

    #s1 is a connection to that service.
    s1 = TCPSocket.open("localhost", @port)
    sleep(0.1)

    #now start closing the server in a separate thread. It cannot
    #finish closing until s1 completes.
    Thread.start {@ss.close}
    sleep(0.1)

    #try to connect to the dying server.
    s2=nil
    Thread.start {s2 = TCPSocket.open("localhost", @port)}
    sleep(0.1)
    assert_equal(nil, s2, "shouldn't have connected")
    assert_not_equal(nil, s1, "Should have connected")

    #Complete the s1 session.
    s1.write("testCloseRaceCondition");
    s1.close

    #collect the pending s2 connection
    testThread = Thread.current
    @ss.serve(@port) {testThread.wakeup}
    Thread.stop
    assert_not_equal(nil, s2)
    s2.close
    @ss.close
  end

  def testSessionCount
    @ss.serve(@port) do |serverSocket|
      message = serverSocket.gets
    end

    s1 = nil;
    Thread.start {s1 = TCPSocket.open("localhost", @port)}
    sleep(0.2)
    assert_equal(1, @ss.pendingSessions);
    s1.write("testSessionCount");
    s1.close
    sleep(0.2)
    assert_equal(0, @ss.pendingSessions)
    @ss.close
  end

  def connect(port)
    s = TCPSocket.open("localhost", @port)
    sleep(0.1)
    s.close
  end
end