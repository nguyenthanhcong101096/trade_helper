# frozen_string_literal: true

require_relative "trade_helper/version"
require 'json'
require 'require_all'
require 'sqlite3'
require 'logger'
require 'technical-analysis'
require "active_support/all"
require 'active_record'

require_all "#{Gem.loaded_specs['trade_helper'].full_gem_path}/lib/binance"

module TradeHelper
  Time.zone = "Asia/Bangkok"

  class Error < StandardError; end
  # Your code goes here...
end
