require 'socket'
require 'timer'
require_relative '../../src/abstract'
require_relative '../../src/reporter'

module Reactor

  class Connection
    include Logger
    include Abstract

    attr_reader :server, :dispatcher
    attr_accessor :connection, :buffer, :closed, :stream, :last_activity
    abstract_methods :post_initialize, :do_read

    def initialize(server, reactor, connection)
      @server = server
      @dispatcher = reactor
      self.connection = connection
      self.closed = false
      self.stream = false

      self.last_activity = Time.now

      self.connection.fcntl(Fcntl::F_SETFL, Fcntl::O_NONBLOCK) #set non blocking connection
      self.connection.setsockopt(Socket::Constants::IPPROTO_TCP, Socket::Constants::TCP_NODELAY, 1)

      self.post_initialize

      self.read_away #try to read asap if we're receiving before attaching the do_read event in the dispatcher
    end

    def read_away

    end



    def clear_buffer
      self.buffer = ''
    end

  end

end