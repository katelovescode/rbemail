require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::RcovFormatter
]
SimpleCov.start

require 'rubygems'
require 'rspec'
require 'rbemail'
require 'rack/test'

RSpec.configure do |config|
  include Rack::Test::Methods

  def app
    Rbemail
  end

  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_framework = :mocha
  # config.mock_framework = :flexmock
  # config.mock_framework = :rr
end
