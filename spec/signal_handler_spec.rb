require 'rspec'
require_relative '../src/signal_handler'


describe 'Signal Handler testing' do
  it 'catches a TERM signal' do
    # The MRI default TERM handler does not cause RSpec to exit with an error.
    # Use the system default TERM handler instead, which does kill RSpec.
    # If you test a different signal you might not need to do this,
    # or you might need to install a different signal's handler.
    old_signal_handler = Signal.trap 'TERM', 'SYSTEM_DEFAULT'

    Reactor::SignalHandler.define_trap(:TERM) do
      puts 'Exiting'
      exit
    end
    expect(Reactor::SignalHandler).to receive(:define_trap).with array_including(:TERM)
    Process.kill 'TERM', 0 # Send the signal to ourself

    # Put the Ruby default signal handler back in case it matters to other tests
    Signal.trap 'TERM', old_signal_handler
  end

  it 'test term_trap exit signal' do
    old_signal_handler = Signal.trap 'TERM', 'SYSTEM_DEFAULT'

    Reactor::SignalHandler.define_term_trap do
      puts 'Exiting'
      exit
    end
    expect(Reactor::SignalHandler).to receive(:define_term_trap)
    Process.kill 'TERM', 0 # Send the signal to ourself

    # Put the Ruby default signal handler back in case it matters to other tests
    Signal.trap 'TERM', old_signal_handler
  end
end