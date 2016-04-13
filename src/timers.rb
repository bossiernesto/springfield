require_relative '../src/abstract'

module Reactor

  class AbstractTimer
    include Comparable
    extend Abstract

    attr_accessor :contained_in, :repeatable, :comparable_time

    abstract_methods :complies

    def add_to_timers
      self.contained_in.timers << self
    end

    def remove_from_timers
      self.contained_in.timers.delete self
      self.contained_in.timers.sort
    end

    def <=>(other)
      self.comparable_time <=> other.comparable_time
    end

    def consume
      contained_in.timers.delete self unless repeatable
    end

    def _comparable_time_to_i(time)
      (time.to_f * 1000).to_i
    end

  end

  class Timer < AbstractTimer
    attr_accessor :fire_time, :quantum

    def initialize(fire_time, contained_in=nil, repeatable=false)
      self.quantum = fire_time * 1000 #-> converting to seconds
      self.repeatable = repeatable
      set_next_time_of_fire

      unless contained_in.nil?
        self.contained_in = contained_in
        self.add_to_timers
      end
    end

    def set_next_time_of_fire
      self.fire_time = _comparable_time_to_i(Time.now) + self.quantum
      self.comparable_time = fire_time
    end

    def set_container(container)
      self.contained_in = container
    end

    def consume
      set_next_time_of_fire if repeatable
      super
    end

    def complies_and_consume
      cmp = self.complies
      self.consume if cmp
      cmp
    end

    def complies
      _comparable_time_to_i(Time.now) >= self.fire_time
    end

  end

  class TimestampTimer < AbstractTimer
    attr_accessor :timestamp_fire

    def initialize(timestamp_fire, contained_in=nil)
      self.timestamp_fire = timestamp_fire
      self.comparable_time = self._comparable_time_to_i timestamp_fire
      self.repeatable = false

      unless contained_in.nil?
        self.contained_in = contained_in
        self.add_to_timers
      end
    end

    def complies
      Time.now >= self.timestamp_fire
    end

  end

  class QuantumTimer < AbstractTimer
    attr_accessor :quantity, :passes

    def initialize(quantity, contained_in=nil, repeatable=false)
      self.passes = 0
      self.comparable_time = self._comparable_time_to_i Time.now
      self.quantity=quantity if quantity.is_a? Integer
      self.repeatable = repeatable

      unless contained_in.nil?
        self.contained_in = contained_in
        self.add_to_timers
      end
    end

    def complies
      return false if self.passes > self.quantity and not repeatable
      self.passes += 1
      self.passes % self.quantity == 0
    end

  end

end