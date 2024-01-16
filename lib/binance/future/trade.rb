module Binance
  class Future
    module Trade
      def cancel_order(symbol:, order_id:)
        request.sign_request(
          method: :delete,
          path: routes.cancel_order_path,
          params: { symbol: symbol, orderId: order_id }
        )
      end

      def new_market_order(symbol:, side:, quantity:, opts: {})
        request.sign_request(
          method: :post,
          path: routes.create_order_path,
          params: {
            symbol: symbol,
            side: side,
            quantity: quantity,
            type: "MARKET",
            positionSide: "BOTH"
          }.merge(opts)
        )
      end

      def positions(symbol: nil)
        request.sign_request(
          method: :get,
          path: routes.position_information_path,
          params: { symbol: symbol }
        )
      end

      def position(symbol:)
        res = positions(symbol: symbol)

        if res.success?
          object = Struct.new(:success?, :data)
          object.new(true, res.data.first)
        else
          res
        end
      end
    end
  end
end