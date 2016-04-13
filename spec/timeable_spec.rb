require 'rspec'
require_relative '../src/timeable'
require_relative '../src/reactor_exceptions'

class TestTimer
  include Reactor::Timeable

  def initialize(timer=nil)
    self.initialize_timers timer
  end
end

describe 'Add timeable specs' do
  it 'Can not add not timer objects' do
    class B

    end
    not_a_timer = B.new
    expect { TestTimer.new(not_a_timer) }.to raise_error(Reactor::TimeableException)

  end

  it 'can add a single timer' do
    timer = Reactor::Timer.new 1 #set to 1 second to comply
    timer_manager = TestTimer.new timer
    expect(timer_manager.timers).to eq([timer])
    sleep 2 #wait long enough to get a comply timer condition
    expect(timer_manager.all_timers_comply?).to eq(true)
  end

  it 'can add multiple timers' do
    timer_manager = TestTimer.new
    timer_manager.add_time_timer 1
    timer_manager.add_time_timer 3
    expect(timer_manager.timers.length).to eq(2)
    sleep 4
    expect(timer_manager.all_timers_comply?).to eq(true)
  end

  it 'compare timers, test 1' do
    timer = Reactor::Timer.new 1 #set to 1 second to comply
    timer2 = Reactor::TimestampTimer.new (Time.now + 3)
    expect(timer2 > timer).to eq(true)
  end

  it 'can add timestamp timer' do
    timer_manager = TestTimer.new
    expire_on = Time.now + 3 #3 seconds from now
    timer_manager.add_timestamp_timer expire_on
    timer_manager.add_time_timer 6
    expect(timer_manager.timers.length).to eq(2)
    sleep 8
    expect(timer_manager.all_timers_comply?).to eq(true)
  end

  it 'compare timers, test 2' do
    timer = Reactor::QuantumTimer.new 3
    timer_2 = Reactor::Timer.new 10 #set to 10 second to comply
    expect(timer_2 > timer).to eq(true)
    sleep(12)
    expect(timer_2.complies).to eq(true)
    expect(timer_2 > timer).to eq(true)
  end

  it 'quantum timer complies test' do
    timer = Reactor::QuantumTimer.new 3
    expect(timer.complies).to eq(false)
    expect(timer.complies).to eq(false)
    expect(timer.complies).to eq(true)
    expect(timer.passes).to eq(3)
  end

  it 'quantum cyclic timer test' do
    timer = Reactor::QuantumTimer.new 2, nil, true
    expect(timer.complies).to eq(false)
    expect(timer.complies).to eq(true)
    expect(timer.passes).to eq(2)
    expect(timer.complies).to eq(false)
    expect(timer.complies).to eq(true)
    expect(timer.passes).to eq(4)
  end

  it 'timer repeatable' do
    timer = Reactor::Timer.new 10, nil, true
    expect(timer.complies).to eq(false)
    sleep(10)
    expect(timer.complies_and_consume).to eq(true)
    expect(timer.complies).to eq(false)
    sleep(10)
    expect(timer.complies).to eq(true)
  end
end