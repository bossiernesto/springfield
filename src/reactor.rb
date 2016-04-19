require 'thread'
require_relative '../src/orderedarray'
require_relative '../src/reporter'
require_relative '../src/abstract'
require_relative '../src/reactor_exceptions'
require_relative '../src/timeable'
require_relative '../src/timers'
require_relative '../src/events'
require_relative '../src/listener'

DEFAULT_QUANTUM = 10 #Time in milliseconds

module Reactor

  class Dispatcher
    include Logger

    attr_accessor :running, :handler_manager_read, :handler_manager_write, :handler_manager_error, :handler_manager_tasks, :on_attach, :on_detach, :ios, :quantum, :debug


    def initialize(debug=false, quantum=DEFAULT_QUANTUM)
      self.debug = debug
      #State for manager lists
      self.handler_manager_read = EventHandlerManager.new :read, self.debug
      self.handler_manager_write = EventHandlerManager.new :write, self.debug
      self.handler_manager_error = EventHandlerManager.new :error, self.debug
      self.handler_manager_tasks = EventHandlerManager.new :tasks, self.debug, false

      #process queue
      self.ios= []

      #Other state for reactor dispatcher
      self.running = true
      self.quantum = quantum

      #Set up the listeners
      self.on_attach = []
      self.on_detach = []
    end

    def is_running?
      running
    end

    def change_reactor_quantum(new_timeout)
      unless new_timeout.is_a? Integer
        msg = "Can not set a non integer value as a valid quantum time. Leaving the quantum in #{self.quantum}"
        self.report_error msg
      end
      self.quantum = new_timeout
      self.report_system "Changing quantum of reactor to #{new_timeout} milliseconds"
    end

    def run
      self.report_system 'Starting main reactor loop'
      yield self if block_given?
      begin
        while is_running?
          run_cycle
        end
      rescue SystemExit, Interrupt
        self.report_system 'Exiting from main reactor loop.'
        exit
      end
    end

    def run_cycle
      read_ios, _dirty_read_ios = get_events_for :read
      write_ios, _dirty_write_ios = get_events_for :write
      error_ios, _dirty_error_ios = get_events_for :error

      event = IO.select(read_ios, write_ios, error_ios, 0.001 * self.quantum)
      if event
        fire_events :read, event[0]
        fire_events :write, event[1]
        fire_events :error, event[2]
      end
      fire_task_events
    end

    def attach_task(handler, wait_if_attached=true, &callback)
      handler.attach wait_if_attached, &callback
    end

    def attach_io(handler, mode, io, wait_if_attached = true, &callback)
      handler.attach_io io, wait_if_attached, &callback
      self.process_on_attach mode, io if self.has_listeners self.on_attach
    end

    def attach_handler(mode, io=nil, wait_if_attached = true, &callback)
      if callback.nil?
        msg = 'A callback block should be passed to the attach_handler.'
        self.report_error msg
        raise ReactorException, msg
      end

      handler_manager = get_handler_manager mode

      if mode_is_task(mode)
        self.report_system "Attaching callback to tasks"
        self.attach_task handler_manager, wait_if_attached, &callback
      else
        self.report_system "Attaching callback to io #{io}"
        self.attach_io handler_manager, mode, io, wait_if_attached, &callback
      end
    end

    def detach_handler(mode, io, force=False)
      handler_manager = get_handler_manager mode
      handler = handler_manager.is_io_included io
      unless handler
        #The io doesn't exits anymore
        return
      end

      self.report_system "Detaching handler #{handler}"
      handler_manager.detach handler, force

      self.process_on_detach mode, io if self.has_listeners self.on_detach
    end

    def detach_all_handlers(mode)
      handler_manager = get_handler_manager mode
      self.report_system "Detaching all handler from mode #{mode}"
      handler_manager.remove_all_events
    end

    def get_handler_manager(mode)
      check_valid_mode mode
      self.instance_variable_get("@handler_manager_#{mode}")
    end

    def get_events_for(mode)
      handler_manager = get_handler_manager mode
      handler_manager.get_events_io
    end

    def fire_task_events
      handler_manager = get_handler_manager :tasks
      handler_manager.events.each do |event|
        event.execute if event.is_a? TaskEvent
      end
    end

    def fire_events mode, ios
      handler_manager = get_handler_manager mode
      ios.each do |io|
        event = handler_manager.get_event io
        self.ios << [io, event.get_callback]
      end
      self.process_ios
    end

    def process_ios
      ios.each { |io| self.process_io io }.clear
    end

    def process_io(io)
      io[1].call io[0], self
    end

    def check_valid_mode(mode)
      unless [:read, :write, :error, :tasks].include? mode
        msg = "Mode #{mode} is not a valid one."
        self.report_error msg
        raise ReactorException, msg
      end
    end

    def mode_is_task(mode)
      mode == :tasks
    end

    #Methods for managing the listeners
    def has_listeners(listener_list)
      listener_list.length > 0
    end

    def add_detach_listener(name, run_once=false, &block)
      listener = Listener.new name, run_once, &block
      self.on_detach << listener
    end

    def add_attach_listener(name, run_once=false, &block)
      listener = Listener.new name, run_once, &block
      self.on_attach << listener
    end

    def remove_all_attach_listeners
      self.on_attach.clear
    end

    def remove_all_detach_listeners
      self.on_detach.clear
    end

    def abstract_process_listeners(listener_list, mode, io=nil)
      listener_list.each do |listener|
        listener.call mode, io
        listener_list.delete listener if listener.run_once?
      end

    end

    def process_on_attach(mode, io=nil)
      self.abstract_process_listeners self.on_attach, mode, io
    end


    def process_on_detach(mode, io=nil)
      self.abstract_process_listeners self.on_detach, mode, io
    end

  end

end


