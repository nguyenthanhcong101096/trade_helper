module Binance
  class Future
    module Account
      def account_info
        request.sign_request(
          method: :get,
          path: routes.account_path
        )
      end

      def transactions(params: {})
        request.sign_request(
          method: :get,
          path: routes.transactions_histories_path,
          params: params
        )
      end
    end
  end
end