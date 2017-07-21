require "spec_helper"

RSpec.describe Ruactor do
  it "has a version number" do
    expect(Ruactor::VERSION).not_to be nil
  end

  it "queues call for execution" do
    class Test
      include Ruactor::Actor

      def foo
        puts :foo
      end
    end

    x = Test.new
    x.send! :foo
    expect(Ruactor::Dispatcher.instance.queue.pop).to eq([x, :foo])
  end

  it "executes tasks in the queue" do
    x = Object.new
    x.singleton_class.class_eval do
      attr_accessor :invoked
    end
    x.invoked = false

    Ruactor::Dispatcher.instance.queue << [x, :invoked=, true]
    Ruactor::Dispatcher.instance.start
    sleep 2
    Ruactor::Dispatcher.instance.stop

    expect(x.invoked).to be(true)
  end

end
