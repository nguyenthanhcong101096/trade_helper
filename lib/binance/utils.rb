module Binance
  module Utils
    module_function

    def binance_time(time)
      return nil if time.nil?

      time.to_i * 1000
    end

    def time_utc7(time)
      Time.zone.at(time.to_i / 1000)
    end

    def interval_to_minutes(interval)
      case interval
      when "1m"  then 1
      when "3m"  then 3
      when "5m"  then 5
      when "15m" then 15
      when "30m" then 30
      when "1h"  then 60
      when "2h"  then 120
      when "4h"  then 220
      when "1d"  then 1440
      else
        1
      end
    end

    def build_query(params)
      params.map do |key, value|
        if value.is_a?(Array)
          value.map { |v| "#{key}=#{v}" }.join("&")
        else
          "#{key}=#{value}"
        end
      end.join("&")
    end

    def add_param(query, key, value)
      query = (query || "").dup
      query << "&#{key}=#{value}"
      query.delete_prefix("&")
    end
  end
end