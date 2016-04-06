module Timeable
  attr_accessor :timers

  def initialize_timers(timer, &block)
    self.timers = OrderedArray.new
    self.timers << timer
    self.callbacks = [block]
  end

  def all_timers_comply?
    self.timers.all? { |timer| timer.complies }
  end

  def add_quantum_timer(quantum, repeatable=false)
    QuantumTimer.new self, quantum, repeatable
  end

  def add_timestamp_timer(time, repeatable=false)
    TimestampTimer.new self, time, repeatable
  end

  def add_time_timer(time, repeatable=false)
    Timer.new self, time, repeatable
  end
end
