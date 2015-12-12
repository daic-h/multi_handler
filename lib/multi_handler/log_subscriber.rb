require "active_record/log_subscriber"

module MultiHandler
  module LogSubscriber
    def sql(event)
      @_conn_name = event.payload[:conn_name]
      super(event)
    end

    def debug(msg)
      conn = @_conn_name ? color("[Connection: #{@_conn_name}]", ActiveSupport::LogSubscriber::GREEN, true) : ""

      super(conn + msg)
    end
  end

  module AbstractAdapter
    class InstrumenterDecorator < ActiveSupport::ProxyObject
      def initialize(instrumenter, adapter)
        @instrumenter = instrumenter
        @adapter = adapter
      end

      def instrument(name, payload = {}, &block)
        payload[:conn_name] ||= @adapter.conn_name
        @instrumenter.instrument(name, payload, &block)
      end

      def method_missing(meth, *args, &block)
        @instrumenter.send(meth, *args, &block)
      end
    end

    def initialize(*)
      super
      @instrumenter = InstrumenterDecorator.new(@instrumenter, self)
    end

    def conn_name
      @config[:conn_name]
    end
  end
end

ActiveRecord::ConnectionAdapters::AbstractAdapter.prepend(MultiHandler::AbstractAdapter)
ActiveRecord::LogSubscriber.prepend(MultiHandler::LogSubscriber)
