require_relative '../src/reporter'

module Reactor
  class Listener
    include Logger

    attr_accessor :callback, :name, :run_once, :debug

    def initialize(name, run_once, debug=False, &block)
      self.name = name
      self.debug = debug
      self.run_once = run_once
      self.callback = block
    end

    def callback=(block)
      self.check_block_arity(&block)
      @callback = block
    end

    def check_block_arity(&block)
      unless block.parameters.length == 2
        self.report_invalid_arity block
      end

      block_params = block.parameters.flat_map { |param| param[1] }
      unless block_params == [:mode, :io]
        msg = "Block params #{block_params} should respect the following contract -> proc {|mode, io| ....},
               for understandable listener code"
        self.report_warning msg
      end
    end

    def run_once?
      self.run_once
    end

    def call(*args)
      self.callback.call(*args)
    end

    protected

    def report_invalid_arity(block)
      msg = "Block #{block} has not 2 parameters. Listener blocks must respect the following contract proc {|mode, io| ...}"
      self.report_error msg
      raise Reactor::ListenerException.new msg
    end

  end

end