module Binance
  class Future
    module Api
      KLINE_LIMIT_REQUEST = 1500

      def exchange_info
        request.public_request(path: routes.exchange_info_path)
      end

      def mark_price(symbol:)
        request.public_request(path: routes.price_path, params: { symbol: symbol }).data[:last_price].to_f
      end

      def klines(symbol:, interval:, limit: 1499, start_time: nil, end_time: nil)
        minutes = Binance::Utils.interval_to_minutes(interval)
        time    = start_time ? start_time.advance(minutes: -minutes) : nil
        query_start_time = Binance::Utils.binance_time(time)
        query_end_time   = Binance::Utils.binance_time(end_time)
        options_params   = { startTime: query_start_time, endTime: query_end_time }

        res = request.public_request(
          path: routes.kline_path,
          params: { symbol: symbol, interval: interval, limit: limit + 1 }.merge(options_params.compact)
        )

        if res.success?
          format_json = proc do |item|
            {
              started_at:             Binance::Utils.time_utc7(item[0]),
              closed_at:              Binance::Utils.time_utc7(item[6]),
              start_time:             item[0],
              date_time:              item[0],
              close_time:             item[6],
              open_price:             item[1].to_f,
              close_price:            item[4].to_f,
              hight_price:            item[2].to_f,
              low_price:              item[3].to_f,
              base_asset_volume:      item[7].to_f,
              color:                  item.last,
              is_kline_close:         true,
            }
          end

          return format_json.call(res.data) if res.data.is_a?(Hash)

          output = []

          res.data.each_with_index do |item, index|
            next if index.zero?

            previous_index = index - 1

            color = item[4].to_f > res.data[previous_index][4].to_f ? 'GREEN' : 'RED'

            output << format_json.call(item.push(color))
          end

          object = Struct.new(:success?, :data)
          object.new(true, output)
        else
          res
        end
      end

      def range_klines(symbol:, interval:, from_time:, to_time:)
        message = Struct.new(:success?, :data)
        time    = from_time
        mins    = Binance::Utils.interval_to_minutes(interval)
        data    = []

        loop do
          start_time = time
          end_time   = time.advance(minutes: mins * KLINE_LIMIT_REQUEST)
          time       = end_time

          if start_time >= to_time
            return message.new(
              true,
              data.flatten.uniq.select { |k| Binance::Utils.time_utc7(k[:start_time]).between?(from_time, to_time )}
            )
          end

          request_kline = klines(symbol: symbol, interval: interval, start_time: start_time, end_time: end_time)

          data << request_kline.data
        end
      rescue
        message.new(false, {})
      end
    end
  end
end