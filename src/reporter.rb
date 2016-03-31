require 'colorize'
require 'time'

module Reactor
  class Reporter
    def self.report_error(msg)
      puts "[#{Time.now.iso8601} - Error] #{msg}".colorize(:color => :red, :background => :black)
    end

    def self.report_info(msg)
      puts "[#{Time.now.iso8601} - Info] #{msg}".colorize(:color => :cyan, :background => :black)
    end

    def self.report_system(msg)
      puts "[#{Time.now.iso8601} - System] #{msg}".colorize(:color => :green, :background => :black)
    end
  end
end