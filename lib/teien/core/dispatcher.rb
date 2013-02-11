module Teien

module Dispatcher
  def initialize(*args, &block)
    super
    @dispatch_receivers = Array.new
  end

  def register_receiver(recv)
    @dispatch_receivers.push(recv)
  end

  def notify(method, *argv)
    @dispatch_receivers.each {|recv|
      if (recv.respond_to?(method))
        recv.method(method).call(*argv)
      end
    }
  end

  def notify_reversely(method, *argv)
    @dispatch_receivers.reverse_each {|recv|
      if (recv.respond_to?(method))
        recv.method(method).call(*argv)
      end
    }
  end
end

end
