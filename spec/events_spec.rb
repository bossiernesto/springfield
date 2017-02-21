require 'rspec'
require_relative '../src/reactor_exceptions'
require_relative '../src/events'

describe 'Testing base events' do

  context 'Testing Base events' do

    context 'Failing tests' do

      it 'should fail if statuses have not been initialized' do
        event = Reactor::BaseEvent.new
        expect { event.change_status :clean }.to raise_error NoMethodError
      end

      it 'should raise an error on setting an invalid status' do
        event = Reactor::BaseEvent.new
        event.initialize_status
        expect { event.change_status :SOme }.to raise_error Reactor::ReactorException
      end

    end

    context 'Successful tests' do
      let(:callback) { Proc.new { 1 } }

      it 'should create a clean status on new base event' do

        event = Reactor::BaseEvent.new
        event.initialize_status

        expect(event.status).to eq :clean
        expect(event.callbacks).to eq []
        expect(event.has_callbacks?).to eq false
      end

      it 'should set status to dirty without issues' do
        event = Reactor::BaseEvent.new
        event.initialize_status

        event.change_status :dirty

        expect(event.status).to eq :dirty
        expect(event.callbacks).to eq []
        expect(event.has_callbacks?).to eq false
      end

      it 'should be able to add callback to base event' do
        event = Reactor::BaseEvent.new
        event.initialize_status

        event.add_callback true, &callback

        expect(event.callbacks.length).to eq 1
        expect(event.status).to eq :clean
      end


      it 'should be able to add dirty callback to base event' do
        event = Reactor::BaseEvent.new
        event.initialize_status

        event.add_callback false, &callback

        expect(event.callbacks.length).to eq 1
        expect(event.status).to eq :dirty
      end

      it 'should remove the callback without issues' do
        event = Reactor::BaseEvent.new
        event.initialize_status

        event.add_callback true, &callback

        expect(event.callbacks.length).to eq 1
        expect(event.has_callbacks?).to be_truthy
        expect(event.get_callback).to eq callback

        event.remove_last_callback

        expect(event.callbacks.length).to eq 0
        expect(event.has_callbacks?).to eq false
      end

    end

  end

  context 'Testing Task events' do

    it 'should be able to execute callbacks' do
      a_variable = 0
      callback = Proc.new { a_variable=1 }
      event = Reactor::TaskEvent.new(&callback)

      expect(event.status).to eq :clean
      expect(event.callbacks.length).to eq 1
      expect(a_variable).to eq 0

      event.execute

      expect(a_variable).to eq 1

      event.remove_last_callback

      expect(event.status).to eq :clean
      expect(event.has_callbacks?).to be false
    end

  end

  context 'Testing EventManager' do
    let(:event_manager) { Reactor::EventHandlerManager.new :read, true, false }
    let(:io_event_manager) { Reactor::EventHandlerManager.new :read, true, true }

    it 'create,attach a Task event, execute it and remove it' do
      outside_variable = 0
      callback = Proc.new { outside_variable = 2 }

      expect(event_manager.events.length).to eq 0

      event_manager.attach(&callback)

      expect(event_manager.events.length).to eq 1

      event_manager.events.each { |e| e.execute }

      expect(outside_variable).to eq 2

      event_manager.remove_all_events
      expect(event_manager.events.length).to eq 0
    end

    it 'detach task event from event manager' do
      callback = Proc.new { 2 }

      expect(event_manager.events.length).to eq 0

      event_manager.attach(&callback)

      expect(event_manager.events.length).to eq 1
      event = event_manager.events[0]

      expect(event.is_a? Reactor::TaskEvent).to be_truthy
      expect(event_manager.is_event_included event).to be_truthy

      event_manager.detach event, false

      expect(event_manager.events.length).to eq 1
      expect(event.has_callbacks?).to eq false

      event_manager.attach(&callback)
      expect(event_manager.events.length).to eq 2
      event_manager.detach event, true

      expect(event.status).to eq :dirty
    end

    it 'should not attach an io callback into a non io event manager' do

      callback = Proc.new { 2 }

      expect { event_manager.attach_io(:read, true, &callback) }.to raise_error

    end

    it 'should attach an io event successfully' do
      callback = Proc.new { 2 }
      callback2 = Proc.new { 4 }

      io_event_manager.attach_io(:read, true, &callback)

      expect(io_event_manager.events.length).to eq 1
      event = io_event_manager.events.first

      expect(event.status).to eq :clean
      expect(event.callbacks.first).to eq callback

      io_event_manager.remove_all_events
      expect(io_event_manager.events.length).to eq 0

      io_event_manager.attach_io(:read, false, &callback)
      expect(io_event_manager.events.length).to eq 1
      event = io_event_manager.events.first

      expect(event.status).to eq :clean

      io_event_manager.attach_io(:read, false, &callback2)
      expect(io_event_manager.events.length).to eq 1
      expect(event.status).to eq :dirty

    end

    it 'should return event from io type' do
      callback = Proc.new { 2 }
      callback2 = Proc.new { 42 }

      io_event_manager.attach_io(:read, true, &callback)
      event = io_event_manager.events.first

      io_event_manager.attach_io(:write, true, &callback2)

      expect(io_event_manager.events.length).to eq 2
      expect(io_event_manager.is_io_included :read).to eq event
      expect(io_event_manager.get_events_io).to eq([[:read, :write], []])
    end

  end

end
