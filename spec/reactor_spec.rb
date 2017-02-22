require 'rspec'
require_relative '../src/reactor'


describe 'test reactor core' do
  let(:reactor) { Reactor::Dispatcher.new }
  let(:callback) { Proc.new { 12 } }

  it 'test write some content with a write event' do
    buffer = ''
    reactor.attach_handler(:write, STDOUT) do
      buffer << 'Hola Mundo!'
    end
    reactor.run_cycle
    expect(reactor).to be_truthy
    expect(reactor.is_running?).to be_truthy
    expect(buffer).to eq('Hola Mundo!')
  end

  it 'change quantum' do
    expect(reactor.quantum).to eq(DEFAULT_QUANTUM)
    reactor.change_reactor_quantum 234
    expect(reactor.quantum).to eq(234)
  end

  it 'quantum should be an integer' do
    expect(reactor.quantum).to eq(DEFAULT_QUANTUM)

    reactor.change_reactor_quantum 234.0
    reactor.change_reactor_quantum '234.0'

    #Should not change quantum actually
    expect(reactor.quantum).to eq(DEFAULT_QUANTUM)
  end

  it 'should raise an exception trying to attach a nil callback' do
    expect { reactor.attach_handler :tasks, nil, nil &nil }.to raise_error Reactor::ReactorException
  end

  it 'should raise execption for invalid task type' do
    expect { reactor.attach_handler :notasks, nil, nil do
      1
    end }.to raise_error Reactor::ReactorException
  end

  it 'should attach a task event' do
    reactor.attach_handler(:tasks, nil, &callback)

    expect(reactor.handler_manager_write.events.length).to eq 0
    expect(reactor.handler_manager_read.events.length).to eq 0
    expect(reactor.handler_manager_tasks.events.length).to eq 1
  end

  it 'should attach an io event' do
    reactor.attach_handler(:write, :io, &callback)

    expect(reactor.handler_manager_write.events.length).to eq 1
    reactor.detach_all_handlers :write
    expect(reactor.handler_manager_write.events.length).to eq 0
  end

  it 'should not attach a non valid callback listener' do
    expect(reactor.has_listeners?).to eq false
    expect(reactor.has_listeners :detach).to eq false
    expect(reactor.has_listeners :attach).to eq false

    expect { reactor.add_attach_listener 'something', false, &callback }.to raise_error Reactor::ListenerException
  end

  it 'should register on attach and detach listener' do
    callback2 = Proc.new { |mode, io| 43 }
    expect(reactor.has_listeners?).to eq false
    expect(reactor.has_listeners :detach).to eq false
    expect(reactor.has_listeners :attach).to eq false

    reactor.add_attach_listener('something', false, &callback2)
    reactor.add_detach_listener('another', false, &callback2)
    expect(reactor.has_listeners?).to be_truthy
    expect(reactor.on_attach.length).to eq 1
    expect(reactor.on_detach.length).to eq 1

    reactor.remove_all_attach_listeners
    expect(reactor.has_listeners :attach).to be false
    expect(reactor.has_listeners :detach).to be_truthy


    reactor.remove_all_detach_listeners
    expect(reactor.has_listeners :detach).to be false
    expect(reactor.has_listeners :attach).to be false
  end
end
