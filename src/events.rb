

module Reactor
  class BaseEvent
    attr_writer :callbacks
    attr_accessor :status, :valid_statuses

    def initialize_status
      self.status = :clean
      self.valid_statuses = [:clean, :dirty]
    end

    def is_dirty?
      self.status == :dirty
    end

    def change_status(status)
      unless self.valid_statuses.include? status
        raise ReactorException, 'Invalid status'
      end
      self.status = status
    end

    def get_callback
      self.callbacks[0]
    end

    def callbacks
      @callbacks ||= []
    end

    def has_callbacks?
      self.callbacks.length > 0
    end

    def remove_last_callback
      self.callbacks.delete self.callbacks[-1]
    end

    def add_callback(wait_if_attached, &callback)
      unless wait_if_attached
        self.callbacks = [callback]
        self.change_status :dirty
        return
      end
      self.callbacks << callback
    end
  end

  class TaskEvent < BaseEvent
    attr_accessor :block

    def initialize(&block)
      self.callbacks = [block]
    end

    def execute
      for callback in self.callbacks
        callback.call
      end
    end

  end

  class TimedEvent < TaskEvent
    include Timeable

    def initialize(timer=nil, block_timer=false, &block)
      if block_timer
        self.initialize_timers timer, true, &block
      else
        self.initialize_timers timer, false
        self.callbacks = [block]
      end
    end

    def execute
      unless self.all_timers_comply?
        return
      end

      super
      self.timers.each { |timer| timer.consume }
      self.timers.sort
    end
  end

  class IOEvent < BaseEvent
    attr_accessor :io, :status, :valid_statuses

    def initialize(io, &callback)
      self.io = io
      self.callbacks = [callback] if callback
      self.initialize_status
    end

  end

  class EventHandlerManager

    attr_accessor :mode, :events, :debug, :io_allowed

    def initialize(mode, debug=false, io_allowed=true)
      self.debug = debug
      self.mode = mode
      self.io_allowed = io_allowed
      self.events = []
    end

    def is_io_included(io)
      self.events.each do |event|
        begin
          if event.io == io
            return event
          end
        rescue NoMethodError
          #Don't do anything just let it pass, log the error on debug
          Reporter.report_error "Event #{event} of type #{event.class} has no knowledge of IO Events."
        end
      end
      nil
    end

    def remove_all_events
      self.events = []
    end

    def attach(_wait_if_attached=true, &callback)
      self.events << (TaskEvent.new(&callback))
    end

    def attach_io(io, wait_if_attached=true, &callback)
      raise EventHandlerException, 'Can not attach an io event to an unallowed io event manager' unless self.io_allowed

      event = self.is_io_included io
      unless event.nil?
        #Add the callback to an existing event
        event.add_callback wait_if_attached, &callback
        return
      end
      self.events << (IOEvent.new io, &callback)
    end

    def detach(event, force)
      if !force && event.has_callbacks?
        event.remove_last_callback
        return
      end

      self.events.delete(event)
      self.change_status :dirty

    end

    def get_events_io
      dirty_events = []
      events = []
      self.events.each do |event|
        if event.is_dirty?
          dirty_events << event.io
        else
          events << event.io
        end
      end
      return events, dirty_events
    end


    def get_event(io)
      self.is_io_included io
    end

  end

end