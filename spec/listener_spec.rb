require 'rspec'
require_relative '../src/reactor_exceptions'
require_relative '../src/listener'

describe 'Listener Specs' do

  context 'Failing tests' do

    it 'should fail with invalid block arity' do
      expect{Reactor::Listener.new 'testListener', true, true do |a|
        a
      end}.to raise_error Reactor::ListenerException
      expect(STDOUT).to receive(:puts).at_most(1).times
    end

    it 'should put a warning with a valid block arity but not in term of parameter names' do
      Reactor::Listener.new 'testListener', true, true do |a, io|
        a
        end
      expect(STDOUT).to receive(:puts).at_most(1).times
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

  end


end