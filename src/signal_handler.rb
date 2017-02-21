module Reactor

  #   Signal.list   #=> {"EXIT"=>0, "HUP"=>1, "INT"=>2, "QUIT"=>3, "ILL"=>4, "TRAP"=>5, "IOT"=>6, "ABRT"=>6, "FPE"=>8, "KILL"=>9, "BUS"=>7, "SEGV"=>11, "SYS"=>31, "PIPE"=>13, "ALRM"=>14, "TERM"=>15, "URG"=>23, "STOP"=>19, "TSTP"=>20, "CONT"=>18, "CHLD"=>17, "CLD"=>17, "TTIN"=>21, "TTOU"=>22, "IO"=>29, "XCPU"=>24, "XFSZ"=>25, "VTALRM"=>26, "PROF"=>27, "WINCH"=>28, "USR1"=>10, "USR2"=>12, "PWR"=>30, "POLL"=>29}
  class SignalHandler

    def self.define_trap(type, &block)
      raise Reactor::SignalHandlerException.new 'Invalid signal type' unless self.valid_trap?(type)
      Signal.trap self.format_signal_type(type), block
    end

    def self.define_int_trap(&block)
      self.define_trap :INT, &block
    end

    def self.define_term_trap(&block)
      self.define_trap :TERM, &block
    end

    def self.format_signal_type(type)
      type.is_a?(Symbol) ? type.to_s : type
    end

    def self.valid_trap?(type)
      formatted_type = self.format_signal_type type
      Signal.list.include? formatted_type
    end
  end

end