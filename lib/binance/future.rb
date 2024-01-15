require 'binance/routes'
require 'binance/request'
require 'binance/future/trade'

module Binance
  class Future
    include Trade

    def initialize(key: '8d6c00f5097f399ea1e5a0bc82c0bbee92ac5833d6b517f2a3635d81b45684b0', secret: '69a5c3715bb27b35ea6ef97fff95d991328e493e5f82d47d38df8d5b1e66c783', testnet: false)
      @request = Binance::Request.new(key: key, secret: secret)
      @testnet = testnet
    end

    private

    attr_reader(:request, :testnet)

    def routes
      testnet ? Binance::Routes::Testnet : Binance::Routes::Future
    end
  end
end