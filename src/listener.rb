module Reactor
  class Listener
    include Logger
    attr_accessor :callback, :name, :run_once

    def initialize(name, run_once, &block)
      self.name = name
      self.run_once = run_once
      self.callback = block
    end

    def check_block_arity &block
      unless block.parameters.length == 2
        msg = "Block #{block} has not 2 parameters. Listener blocks must respect the following contract proc {|mode, io| ...}"
        self.report_error msg
        raise ListenerException msg
      end
    end

    def run_once?
      self.run_once
    end

  end

end