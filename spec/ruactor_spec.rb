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
    expect(Ruactor::Dispatcher.instance.queue.pop).to eq([x, :foo, [], nil])
  end

  it "executes tasks with blocks" do
    x = [1,2,3]
    x.singleton_class.class_eval do
      include Ruactor::Actor
    end
    x.send! :map! do |c|
      c*2
    end
    Ruactor::Dispatcher.instance.start
    sleep 2
    Ruactor::Dispatcher.instance.stop
    expect(x).to eq([2,4,6])
  end

  it "executes tasks with arguments and blocks" do
    x = [1,2,3]
    x.singleton_class.class_eval do
      include Ruactor::Actor
    end
    x.send! :instance_exec, 1  do |i|
      map! do |j|
        i+j
      end
    end
    Ruactor::Dispatcher.instance.start
    sleep 2
    Ruactor::Dispatcher.instance.stop
    expect(x).to eq([2,3,4])
  end

  it "executes tasks in the queue" do
    x = Object.new
    x.singleton_class.class_eval do
      attr_accessor :invoked
    end
    x.invoked = false

    Ruactor::Dispatcher.instance.queue << [x, :invoked=, true, nil]
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
