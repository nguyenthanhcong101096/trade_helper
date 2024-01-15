require 'faraday'
require_relative "middleware/timestamp"
require_relative "middleware/signature"
require_relative "utils"

module Binance
  class Request
    include Middleware
    include Utils

    attr_reader(:key, :secret)

    def initialize(key: nil, secret: nil)
      @key = key
      @secret = secret
    end

    def public_request(path: "/", params: {}, response_template: nil)
      process_request(public_connection, :get, path, params, response_template)
    end

    def limit_request(method: :get, path: "/", params: {}, response_template: nil)
      process_request(limit_connection, method, path, params, response_template)
    end

    def sign_request(method: :post, path:, params: {}, response_template: nil)
      process_request(signed_connection, method, path, params, response_template)
    end

    private

    def process_request(conn, method, path, params, response_template)
      res = conn.send(method, path_with_query(path, params.compact), nil)
      handle_response(res, response_template)
    end

    def public_connection
      connection
    end

    def limit_connection
      connection do |conn|
        conn.headers["X-MBX-APIKEY"] = key
      end
    end

    def signed_connection
      connection do |conn|
        conn.headers["X-MBX-APIKEY"] = key
        conn.use Timestamp
        conn.use Signature, secret
      end
    end

    def connection
      Faraday.new do |client|
        prepare_headers(client)
        client.options.timeout = 1000
        yield client if block_given?
      end
    end

    def path_with_query(path, params)
      "#{path}?#{build_query(params)}"
    end

    def prepare_headers(client)
      client.headers["Content-Type"] = "application/json"
      client.headers["User-Agent"] = "binance-future-bot"
    end

    def handle_response(res, template)
      if [200, 201].include?(res.status)
        body     = res.body
        response = template ? template.mapping(JSON.parse(body)) : JSON.parse(body)
        struct_message(true, body.nil? ? {} : response)
      else
        status_code = JSON.parse(res.body)["code"]

        msg = {
          "-1111" => "Precision is over the maximum defined for this asset.",
          "-1117" => "Invalid side",
          "-2014" => "API-key format invalid.",
          "-2019" => "Margin is insufficient",
          "-1021" => "Timestamp for this request is outside of the recvWindow.",
          "-2027" => "Exceeded the maximum allowable position at current leverage."
        }[status_code.to_s] || res.body

        struct_message(false, msg + " (from #{self.class.name})")
      end
    end

    def struct_message(status, data)
      object = Struct.new(:success?, :data)
      object.new(status, data)
    end
  end
end