require 'logger'
require 'websocket-eventmachine-client'
require 'binance/socket/callbacks'

module Binance
  module Socket
    class Base
      include Callbacks

      def initialize(options = {})
        @logger = options[:logger] || Logger.new($stdout)
        @base_url = options[:base_url]
        @ws_connection = nil
      end

      def stream(&block)
        EM.run(&block)
      end

      def create_connection(url, cbs)
        @ws_connection = ::WebSocket::EventMachine::Client.connect(uri: url)
        add_callbacks(cbs)
      rescue => ex
        create_connection(url, cbs)
      end

      def subscribe_to(url, cbs)
        create_connection(url, cbs)
      end

      private

      def add_callbacks(cbs)
        # check allowed callbacks
        if %i(onopen onmessage onping onpong onerror onclose).union(cbs.keys).size > 6
          raise ArgumentError, "Only :onopen, :onmessage, :onclose, :onping, :onpong, :onerror allowed"
        end

        onmessage(cbs)
        onerror(cbs)
        onping(cbs)
        onpong(cbs)
        onclose(cbs)
      end

      def onopen(cbs)
        @ws_connection.onopen do
          @logger.debug("connected to server")
          event_callback(cbs, :onopen)
        end
      end

      def onmessage(cbs)
        @ws_connection.onmessage do |msg, type|
          cbs[:onmessage].call(msg, @ws_connection) if cbs.key?(:onmessage) && cbs[:onmessage].respond_to?(:call)
        end
      end

      def onerror(cbs)
        @ws_connection.onerror do |error|
          @logger.error("Error occured: #{error}")
          event_callback(cbs, :onerror, error)
        end
      end

      def onping(cbs)
        @ws_connection.onping do
          @logger.info("Received ping from server")
          @ws_connection.pong
          @logger.info("Responded pong to server")
          event_callback(cbs, :onping)
        end
      end

      def onpong(cbs)
        @ws_connection.onpong do
          @logger.info("Received pong from server")
          event_callback(cbs, :onpong)
        end
      end

      def onclose(cbs)
        @ws_connection.onclose do
          @logger.info("Closed from server")
          event_callback(cbs, :onclose, @ws_connection)
        end
      end

      def event_callback(cbs, event, data = nil)
        cbs[event].call(data) if cbs.key?(event) && cbs[event].respond_to?(:call)
      end
    end
  end
end