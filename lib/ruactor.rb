require "ruactor/version"
require 'thread'
require 'singleton'

module Ruactor
  module Actor

    def send! (name, *args)
      Dispatcher.instance.queue << [self, name, *args]
    end

  end

  class Dispatcher
    include Singleton

    attr_reader :queue

    def initialize()
      @queue = Queue.new
    end

    def start
      @threads = []
      10.times do
        thread = Thread.new do
          loop do
            obj, method, *args = @queue.pop
            obj.send method, *args
          end
        end
        @threads << thread
      end
    end

    def stop
      @threads.each { |t| t.exit }
      @threads.each { |t| t.join }
    end
  end
end
