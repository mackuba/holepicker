require 'logger'
require 'rainbow'

module HolePicker
  class Logger < ::Logger
    attr_accessor :color

    def initialize(io)
      super
      self.level = INFO
      self.color = true
    end

    def format_message(level, datetime, progname, message)
      progname == 'print' ? message.to_s : "#{message}\n"
    end

    def print(message, level = INFO)
      add(level, message, 'print')
    end

    def fail(message)
      error(color ? message.color(:red) : message)
    end

    def success(message)
      info(color ? message.color(:green) : message)
    end
  end

  module HasLogger
    def logger
      @logger ||= HolePicker.logger
    end

    def self.included(c)
      c.class_eval do
        attr_writer :logger
        extend HasLogger
      end
    end
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end
