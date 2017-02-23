require_relative '../../src/reactor'
require_relative '../../src/abstract'

module Reactor

  class Server
    include Abstract
    include Logger

    attr_accessor :connections, :timeout, :server_handler, :sock_server
    attr_reader :reactor

    def initialize
      self.connections = {}
      self.reactor = Reactor::Dispatcher.new
      self.server_handler = Reactor::Connection
      self.timeout = 120.seconds
    end

  end

  def start_server
    this = self
    self.reactor.attach_handler(:read, self.sock_server) do |socket, reactor|
      begin
        loop do
          conn = socket.accept_nonblock
          begin
            request_handler = @server_handler.new(self, reactor, conn)
          rescue Exception => e
            Reactor::Reporter.report_error e
            Reactor::Reporter.report_error e.backtrace
            request_handler.close(false)	# close the request now
          end
        end
      rescue Exception => e
        Reactor::Reporter.report_system 'Exiting server, reasons:'
        Reactor::Reporter.report_system e
      end
    end

    self.attach_periodical_block 1 do
      unless this.connections.empty?
        time = Time.now
        while time - this.connections.first[1].last_active	>= this.timeout
          id, conn = *(this.connections.shift)
          conn.close(false)
        end
      end
    end

  end

  def stop
    self.stop_sock_server
    self.conections.each {|c| c.close}
    self.connections.clear
  end

  def stop_sock_server
    self.reactor.detach_handler(:read, self.sock_server)
    self.sock_server.close
  end

end