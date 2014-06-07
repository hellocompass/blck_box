require 'active_support/core_ext'

ENV['RAILS_ENV'] ||= 'test'

RSpec.configure do |config|

  config.filter_run_excluding :migration => true
  config.filter_run_excluding :broken => true
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.mock_with :rspec

  config.order = 'random'
end