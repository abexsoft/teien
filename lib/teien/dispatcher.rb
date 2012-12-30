module Teien

module Dispatcher
  def initialize(*args, &block)
    super
    @receivers = Array.new
  end

  def register_receiver(recv)
    @receivers.push(recv)
  end

  def notify(method, *argv)
    @receivers.each {|recv|
      if (recv.respond_to?(method))
        recv.method(method).call(*argv)
      end
    }
  end
end

end
