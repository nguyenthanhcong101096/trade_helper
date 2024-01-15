module Binance
  class Future
    module Trade
      def new_market_order
        puts routes.exchange_info_path
      end
    end
  end
end