require 'rspec'
require_relative '../src/abstract'

# Usage:
class AbstractBaseWidget
  extend Abstract

  abstract_methods :widgetify
end

class SpecialWidget < AbstractBaseWidget
end

class ImplementedWidget
  def widgetify
    2
  end
end

describe 'Abstract tests' do

  it 'abstract method' do
    expect {SpecialWidget.new.widgetify}.to raise_error NotImplementedError
  end

  it 'non abstract method' do
    expect(ImplementedWidget.new.widgetify).to eq(2)
  end

end