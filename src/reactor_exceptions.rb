module Reactor
  class ListenerException < StandardError
  end

  class EventHandlerException < StandardError
  end

  class ReactorException < StandardError
  end

  class TimeableException < StandardError
  end

  class SignalHandlerException < StandardError
  end
end