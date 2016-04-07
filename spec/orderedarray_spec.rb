require 'rspec'
require_relative '../src/orderedarray'


describe 'Test Ordered Array' do

  it 'add a value to empty array' do
    array = OrderedArray.new

    array << 1

    expect(array).to eq([1])
  end

  it 'add a value between two values' do
    array = OrderedArray.new [1, 2, 3]
    array << 5
    array << 4

    expect(array).to eq([1, 2, 3, 4, 5])

  end

  it 'Add strings to an ordered array' do
    array = OrderedArray.new ['a', 'b']
    array << 'ccc'
    array << 'z'

    expect(array).to eq(["a", "b", "ccc", "z"])
  end

end