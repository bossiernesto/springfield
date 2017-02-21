require 'rspec'
require_relative '../src/reactor_exceptions'
require_relative '../src/signal_handler'

describe 'Signal Handler testing' do


  it 'fails when setting an invalid signal' do
    expect { Reactor::SignalHandler.define_trap :SOMETHING do
      exit
    end }.to raise_error Reactor::SignalHandlerException

  end

  it 'catches a TERM signal' do
    # The MRI default TERM handler does not cause RSpec to exit with an error.
    # Use the system default TERM handler instead, which does kill RSpec.
    # If you test a different signal you might not need to do this,
    # or you might need to install a different signal's handler.
    pid = fork do
      Reactor::SignalHandler.define_trap(:TERM) do
        exit
      end
      expect(Reactor::SignalHandler).to receive(:define_trap).with array_including(:TERM)
      Signal.should_receive(:trap).at_most(1).times
    end

    Process.detach(pid)
    Process.kill :TERM, pid # Send the signal to ourself
  end

  it 'test term_trap exit signal' do
    pid = fork do
      Reactor::SignalHandler.define_term_trap do
        exit
      end
      expect(Reactor::SignalHandler).to receive(:define_term_trap)
      Signal.should_receive(:trap).at_most(1).times
    end

    Process.detach(pid)
    Process.kill :TERM, pid # Send the signal to ourself
  end
end