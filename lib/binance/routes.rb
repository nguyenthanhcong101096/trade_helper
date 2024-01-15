module Binance
  module Routes
    module Base
      def method_missing(method, **args, &block)
        route = routes[method.to_sym]

        return super if route.nil?

        generate_url(route, args)
      end

      def respond_to_missing?(name, _include_private)
        raise name
      end

      private

      def base_url
        case to_s
        when "Binance::Routes::Future"
          'https://testnet.binancefuture.com'
        when "Biance::Routes::Testnet"
          FutureBotConnector.configure.test_fapi_url
        else
          raise "Missing base url setting"
        end
      end

      def generate_url(route, args)
        uri = route[:path]

        args.each { |k, v| uri.gsub! "{#{k}}", v.to_s }

        [base_url, uri].join
      end
    end

    module Testnet
      class << self
        include Base

        def routes
          {
            create_order_path:           {path: "/fapi/v1/orders"},
            position_information_path:   {path: "/fapi/v1/orders"}
          }
        end
      end
    end

    module Future
      class << self
        include Base

        def routes
          {
            exchange_info_path:          {path: "/fapi/v1/exchangeInfo"},
            kline_path:                  {path: "/fapi/v1/klines"},
            account_info_path:           {path: "/fapi/v2/account"},
            future_account_balance_path: {path: "/fapi/v2/balance"},
            create_order_path:           {path: "/fapi/v1/order"},
            get_orders_path:             {path: "/fapi/v1/order"},
            get_all_open_order_path:     {path: "/fapi/v1/openOrders"},
            all_orders_path:             {path: "/fapi/v1/allOrders"},
            account_trade_list_path:     {path: "/fapi/v1/userTrades"},
            transactions_histories_path: {path: "/fapi/v1/income"},
            position_information_path:   {path: "/fapi/v2/positionRisk"},
            leverage_path:               {path: "/fapi/v1/leverage"},
            mergin_path:                 {path: "/fapi/v1/marginType"},
            account_path:                {path: "/fapi/v2/account"},
            cancel_order_path:           {path: "/fapi/v1/order"},
            price_path:                  {path: "/fapi/v1/ticker/24hr"},
            leverage_bracket_path:       {path: "/fapi/v1/leverageBracket"},
            asset_index_path:            {path: "/fapi/v1/assetIndex"},
            create_listen_key_path:      {path: "/fapi/v1/listenKey"}
          }
        end
      end
    end
  end
end
