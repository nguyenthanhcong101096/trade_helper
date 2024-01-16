module Binance
  class Future
    module Margin
      def change_leverage(symbol:, leverage:)
        request.sign_request(
          method: :post,
          path: routes.leverage_path,
          params: { symbol: symbol, leverage: leverage }
        )
      end

      def change_marge_type(symbol:, margin_type:)
        request.sign_request(
          method: :post,
          path: routes.mergin_path,
          params: {symbol: symbol, marginType: margin_type}
        )
      end
    end
  end
end