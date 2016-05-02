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
end