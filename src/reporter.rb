require 'colorize'
require 'time'

module Reactor
  class Reporter
    def self.format_report(msg, type, color, timestamp)
      String.disable_colorization = false
      if timestamp
        puts "[#{Time.now.iso8601} - #{type}] #{msg}".colorize(:color => color, :background => :black)
      else
        puts "[#{type}] #{msg}".colorize(:color => color, :background => :black)
      end
    end

    def self.report_error(msg, timestamp=true)
      self.format_report msg, 'Error', :red, timestamp
    end

    def self.report_info(msg, timestamp=true)
      self.format_report msg, 'Info', :cyan, timestamp
    end

    def self.report_system(msg, timestamp=true)
      self.format_report msg, 'System', :green, timestamp
    end

    def self.report_warning(msg, timestamp=true)
      self.format_report msg, 'Warning', :yellow, timestamp
    end
  end

  module Logger
    def report_error(msg, timestamp=true)
      method = __method__.to_s.split('_')[1]
      self.report_generic method, msg, timestamp
    end

    def report_info(msg, timestamp=true)
      method = __method__.to_s.split('_')[1]
      self.report_generic method, msg, timestamp
    end

    def report_system(msg, timestamp=true)
      method = __method__.to_s.split('_')[1]
      self.report_generic method, msg, timestamp
    end

    def report_warning(msg, timestamp=true)
      method = __method__.to_s.split('_')[1]
      self.report_generic method, msg, timestamp
    end

    protected

    def report_generic(method, msg, timestamp=true)
      Reactor::Reporter.send "report_#{method}", msg, timestamp if self.debug
    end
  end
end

