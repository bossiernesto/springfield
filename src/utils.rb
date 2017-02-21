def get_dev_null
  RUBY_PLATFORM =~ /mswin/ ? 'NUL:' : '/dev/null'
end


def silence_streams(*streams)
  on_hold = streams.collect { |stream| stream.dup }
  streams.each do |stream|
    stream.reopen get_dev_null
    stream.sync = true
  end
  yield
ensure
  streams.each_with_index do |stream, i|
    stream.reopen(on_hold[i])
  end
end