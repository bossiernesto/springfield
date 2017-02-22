require_relative '../../src/reactor'
require_relative '../../src/abstract'

module Reactor

  class Server
    include Abstract

    attr_accessor :connections, :timeout, :server_handler, :sock_server
    attr_reader :reactor

    def initialize
      self.connections = {}
      self.reactor = Reactor::Dispatcher.new
      self.server_handler = Reactor::Connection
      self.timeout = 120.seconds
    end

  end

end