# frozen_string_literal: true

require_relative "lib/trade_helper/version"

Gem::Specification.new do |spec|
  spec.name = "trade_helper"
  spec.version = TradeHelper::VERSION
  spec.authors = ["nguyenthanhcong101096"]
  spec.email = ["nguyenthanhcong101096@gmail.com"]

  spec.summary = "Support trade API binance...etc."
  spec.description = "Support trade API binance...etc."
  spec.homepage = "https://github.com/nguyenthanhcong101096/future_bot_connector"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://github.com/nguyenthanhcong101096/future_bot_connector"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nguyenthanhcong101096/future_bot_connector"
  spec.metadata["changelog_uri"] = "https://github.com/nguyenthanhcong101096/future_bot_connector/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "activesupport", '~> 7.0.4'
  spec.add_runtime_dependency 'faraday', '~> 1.8'
  spec.add_runtime_dependency 'websocket-eventmachine-client', '~> 1.3'
  spec.add_runtime_dependency 'technical-analysis', '~> 0.2.4'
  spec.add_runtime_dependency 'sqlite3'
  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
