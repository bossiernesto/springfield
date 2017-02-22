require 'rspec'
require_relative '../src/reactor_exceptions'
require_relative '../src/listener'
require_relative '../src/utils'


describe 'Listener Specs' do


  context 'Failing tests' do

    it 'should fail with invalid Proc block arity' do
      callback = Proc.new { 232 }
      silence_streams STDOUT do
        expect { Reactor::Listener.new('testListener', true, true, &callback) }.to raise_error Reactor::ListenerException
        expect(STDOUT).to receive(:puts).at_most(1).times
      end
    end

    it 'should fail with invalid block arity' do
      silence_streams STDOUT do
        expect { Reactor::Listener.new 'testListener', true, true do |a|
          a
        end }.to raise_error Reactor::ListenerException
        expect(STDOUT).to receive(:puts).at_most(1).times
      end
    end

    it 'should put a warning with a valid block arity but not in term of parameter names' do
      silence_streams STDOUT do

        Reactor::Listener.new 'testListener', true, true do |a, io|
          a
        end
        expect(STDOUT).to receive(:puts).at_most(1).times
      end
    end

  end

  context 'Successful tests' do

    it 'should create a Listener and respond successfully' do
      external_variable = 0

      listener = Reactor::Listener.new 'testListener', true, true do |mode, io|
        external_variable = 1
      end

      expect(listener).to be_a Reactor::Listener

      listener.call :mode, :io

      expect(external_variable).to eq 1

    end

    it 'success wit proc' do
      external_variable = 323
      callback = Proc.new { |mode, io| external_variable = 1 }

      silence_streams STDOUT do
        listener = Reactor::Listener.new('testListener', true, true, &callback)

        listener.call :mode, :io

        expect(external_variable).to eq 1
      end

    end

  end


end