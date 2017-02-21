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
      event = Reactor::TaskEvent.new &callback

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

end
