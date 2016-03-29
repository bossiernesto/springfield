require_relative '../src/reactor'
require 'socket'
buffer = ''
port = 46473
server = TCPServer.new("0.0.0.0", port)
reactor = Reactor::Dispatcher.new
reactor.attach_handler(:read, server) do |server|
  conn = server.accept
  conn.write("HTTP/1.1 200 OK\r\nContent-Length:#{buffer.length}\r\nContent-Type:text/plain\r\n\r\n#{buffer}")
  conn.close
end
reactor.attach_handler(:read, STDIN) do
  data = gets
  puts data
  buffer << data
end
reactor.run
