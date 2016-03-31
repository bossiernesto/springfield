require_relative '../src/reactor'

reactor = Reactor::Dispatcher.new true
reactor.change_reactor_quantum 'error coming'
reactor.change_reactor_quantum 3000
reactor.attach_handler(:tasks, nil) do
  puts 'bleh'
  $stderr.puts "Error generado"
end

reactor.attach_handler(:error, STDERR) do
  msg = $stderr.gets
  puts "Error: #{msg}"
end
reactor.run
