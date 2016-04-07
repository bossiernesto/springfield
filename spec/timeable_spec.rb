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
end