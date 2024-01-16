module Binance
  module Socket
    module Callbacks
      module Common
        class << self
          def setup_logger
            require "logger"
            logger = Logger.new($stdout)
            logger.level = Logger::INFO
            logger
          end
        end
      end

      private

      def callbacks
        {
          onopen:    on_open,
          onmessage: on_message,
          onerror:   on_error,
          onclose:   on_close
        }
      end

      def on_open
        proc { logger.info("connected to server") }
      end

      def on_message
        proc { |msg, _ws| puts msg }
      end

      def on_error
        proc { |e| logger.error(e) }
      end

      def on_close
        proc { logger.info("connection closed") }
      end

      def logger
        @logger ||= Common.setup_logger
      end
    end
  end
end