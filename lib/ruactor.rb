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
      @started = false
      @lock = Mutex.new
    end

    def start
      @lock.synchronize {
        unless started?
          @threads = []
          5.times do
            thread = Thread.new do
              loop do
                obj, method, *args = @queue.pop
                obj.send method, *args
              end
            end
            @threads << thread
          end
          @started = true
        end
      }
    end

    def stop
      @lock.synchronize {
        @threads.each { |t| t.exit }
        @threads.each { |t| t.join }
        @started = false
      }
    end

    def started?
      @started
    end

    def stopped?
      !started?
    end
  end
end

Ruactor::Dispatcher.instance.start
at_exit { Ruactor::Dispatcher.instance.stop}
