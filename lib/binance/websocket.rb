require 'binance/socket/base'

class Binance::Websocket < Binance::Socket::Base
  def initialize(options: {})
    options[:base_url] = 'wss://stream.binancefuture.com'
    super(options)
  end

  def kline(symbol:, interval:, **cbs)
    onmessage = proc do |data, _ws|
      parse_data = JSON.parse(data)
      yield(kline_object(parse_data))
    end

    stream do
      url = "#{@base_url}/ws/#{symbol.downcase}@kline_#{interval}"
      create_connection(url, override_callbacks({onmessage: onmessage}))
    end
  end

  def mark_price(symbol:, &block)
    onmessage = proc do |data, _ws|
      parse_data = JSON.parse(data)
      yield(price_object(parse_data))
    end

    stream do
      url = "#{@base_url}/ws/#{symbol.downcase}@markPrice@1s"
      create_connection(url, override_callbacks({onmessage: onmessage}))
    end
  end

  def mark_prices(&block)
    onmessage = proc do |data, _ws|
      parse_data = JSON.parse(data)
      yield(parse_data.map { |item| price_object(item) })
    end

    stream do
      url = "#{@base_url}/ws/!markPrice@arr@1s"
      create_connection(url, override_callbacks({onmessage: onmessage}))
    end
  end

  private

  def override_callbacks(cbs)
    cbs.each_with_object(callbacks) do |(cb_name, function), hash|
      hash[cb_name.to_sym] = function if function.respond_to?(:call)
    end
  end

  private

  def price_object(item)
    {
      event_name: item['e'],
      event_time: item['E'],
      symbol:     item['s'],
      mark_price: item['p'].to_f,
    }
  end

  def kline_object(item)
    {
      event_time:             item["E"],
      start_time:             item["k"]["t"],
      date_time:              item["k"]["t"],
      close_time:             item["k"]["T"],
      symbol:                 item["k"]["s"],
      interval:               item["k"]["i"],
      open_price:             item["k"]["o"].to_f,
      close_price:            item["k"]["c"].to_f,
      hight_price:            item["k"]["h"].to_f,
      low_price:              item["k"]["l"].to_f,
      base_asset_volume:      item["k"]["q"].to_f,
      is_kline_close:         item["k"]["x"],
    }
  end
end