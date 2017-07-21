require "spec_helper"

RSpec.describe Ruactor do

  before(:each) do
    Ruactor::Dispatcher.instance.stop
  end

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

  it "can start and stop the dispatcher" do
    expect(Ruactor::Dispatcher.instance.stopped?).to be(true)
    Ruactor::Dispatcher.instance.start
    expect(Ruactor::Dispatcher.instance.started?).to be(true)
    Ruactor::Dispatcher.instance.stop
    expect(Ruactor::Dispatcher.instance.stopped?).to be(true)
  end

end
