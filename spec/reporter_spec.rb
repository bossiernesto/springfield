require 'rspec'
require_relative '../src/reporter'

describe 'test reporter module' do

  it 'test report info' do
    expect(STDOUT).to receive(:puts).at_most(2).times
    Reactor::Reporter.report_info 'string'
    Reactor::Reporter.report_info 'another info message'
  end

  it 'test report info without timestamp' do
    expect(STDOUT).to receive(:puts).at_most(1).times.with("\e[0;36;40m[Info] some msg\e[0m")
    Reactor::Reporter.report_info 'some msg', false
  end

  it 'test report error without timestamp' do
    expect(STDOUT).to receive(:puts).at_most(1).times.with("\e[0;31;40m[Error] some error msg\e[0m")
    Reactor::Reporter.report_error 'some error msg', false
  end

  it 'test report error without timestamp' do
    expect(STDOUT).to receive(:puts).at_most(1).times.with("\e[0;32;40m[System] some system msg\e[0m")
    Reactor::Reporter.report_system 'some system msg', false
  end

  it 'test report warning without timestamp' do
    expect(STDOUT).to receive(:puts).at_most(1).times.with("\e[0;33;40m[Warning] some warning msg\e[0m")
    Reactor::Reporter.report_warning 'some warning msg', false
  end


  context 'Test Logger module' do

    class UsingLogger
      include Reactor::Logger

      attr_accessor :debug

      def initialize
        self.debug = true
      end

    end

    it 'should log info' do
      instance = UsingLogger.new

      expect(STDOUT).to receive(:puts).at_most(1).times.with("\e[0;36;40m[Info] some msg\e[0m")
      instance.report_info 'some msg', false
    end

    it 'should log warning' do
      instance = UsingLogger.new

      expect(STDOUT).to receive(:puts).at_most(1).times.with("\e[0;33;40m[Warning] some msg\e[0m")
      instance.report_warning 'some msg', false
    end


    it 'should log error' do
      instance = UsingLogger.new

      expect(STDOUT).to receive(:puts).at_most(1).times.with("\e[0;31;40m[Error] some msg\e[0m")
      instance.report_error 'some msg', false
    end

    it 'should log system' do
      instance = UsingLogger.new

      expect(STDOUT).to receive(:puts).at_most(1).times.with("\e[0;32;40m[System] some msg\e[0m")
      instance.report_system 'some msg', false
    end
  end
end