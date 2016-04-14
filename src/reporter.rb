require 'colorize'
require 'time'

module Reactor
  class Reporter
    def self.format_report(msg, type, color, timestamp)
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
  end

  module Logger
    def report_error(msg)
      Reactor::Reporter.report_error msg if self.debug
    end

    def report_info(msg)
      Reactor::Reporter.report_info msg if self.debug
    end

    def report_system(msg)
      Reactor::Reporter.report_system msg if self.debug
    end
  end
end

