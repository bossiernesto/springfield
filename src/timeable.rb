require_relative '../src/orderedarray'
require_relative '../src/timers'

module Reactor

  module Timeable
    attr_accessor :timers, :execute_block

    def initialize_timers(timer=nil, execute_block=false, &block)
      self.execute_block = execute_block
      self.timers = OrderedArray.[]
      if timer
        raise Reactor::TimeableException unless timer.is_a? Reactor::Timer
        self.timers << timer
      end
      self.callbacks = [block] if block
    end

    def all_timers_comply?
      self.timers.all? { |timer| timer.complies }
    end

    def add_quantum_timer(quantum, repeatable=false)
      Reactor::QuantumTimer.new quantum, self, repeatable
    end

    def add_timestamp_timer(time)
      Reactor::TimestampTimer.new time, self
    end

    def add_time_timer(time, repeatable=false)
      Reactor::Timer.new time, self, repeatable
    end

  end

end