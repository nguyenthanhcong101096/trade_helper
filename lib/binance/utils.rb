module Binance
  module Utils
    module_function

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