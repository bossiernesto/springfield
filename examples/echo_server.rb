require_relative '../src/reactor'
require 'socket'
require_relative '../src/reporter'

buffer = ''
port = 46473
host = "0.0.0.0"
server = TCPServer.new(host, port)
Reactor::Reporter.report_info "Stating TCP Server on port #{port} at host #{host} "
reactor = Reactor::Dispatcher.new true
reactor.attach_handler(:read, server) do |my_server|
  conn = my_server.accept
  conn.write("HTTP/1.1 200 OK\r\nContent-Length:#{buffer.length}\r\nContent-Type:text/plain\r\n\r\n#{buffer}")
  conn.close
end
reactor.attach_handler(:read, STDIN) do
  data = gets
  puts data
  buffer << data
end
reactor.run
