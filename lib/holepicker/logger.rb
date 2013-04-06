require 'logger'
require 'rainbow'

module HolePicker
  class Logger < ::Logger
    def initialize(io)
      super
      self.level = INFO
    end

    def format_message(level, datetime, progname, message)
      progname == 'print' ? message.to_s : "#{message}\n"
    end

    def print(message)
      add(INFO, message, 'print')
    end

    def fail(message)
      error(message.color(:red))
    end

    def success(message)
      info(message.color(:green))
    end
  end

  module HasLogger
    def logger
      HolePicker.logger
    end

    def self.included(c)
      c.extend(self)
    end
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end
