class OrderedArray < Array

  def self.[] *array
    OrderedArray.new(array)
  end

  def initialize(array=nil)
    return super(array.sort) if array
    super()
  end

  def index_search(a, e)
    index = [*a.each_with_index].bsearch { |x, _| x > e }
    unless index
      return a.length
    end
    index.last
  end

  def << value
    unless self.length > 0
      return self.insert(0, value)
    end

    index = index_search self, value

    self.insert(index, value)
  end

  alias push <<
  alias shift <<

end
