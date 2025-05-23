# frozen_string_literal: true

require "bundler/setup"
begin
  require "debug/prelude"
rescue LoadError
end

require "resque"
require "resque-retry"

# Allow customization of the Redis instance used for tests
Resque.redis = ENV["REDIS_URL"] if ENV.key?("REDIS_URL")

# To workaround https://github.com/steveklabnik/mono_logger/issues/13
# Note: mono_logger is resque's default logger
Resque.logger = ::Logger.new(nil)

require "sentry-ruby"
require "sentry/test_helper"

require 'simplecov'

SimpleCov.start do
  project_name "sentry-resque"
  root File.join(__FILE__, "../../../")
  coverage_dir File.join(__FILE__, "../../coverage")
end

if ENV["CI"]
  require 'simplecov-cobertura'
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
end

require "sentry-resque"

DUMMY_DSN = 'http://12345:67890@sentry.localdomain/sentry/42'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before :each do
    # Make sure we reset the env in case something leaks in
    ENV.delete('SENTRY_DSN')
    ENV.delete('SENTRY_CURRENT_ENV')
    ENV.delete('SENTRY_ENVIRONMENT')
    ENV.delete('SENTRY_RELEASE')
    ENV.delete('RACK_ENV')
  end

  config.around do |example|
    ENV["FORK_PER_JOB"] = 'false'
    Resque.redis.del "queue:default"
    example.run
    ENV["FORK_PER_JOB"] = ''
  end

  config.include(Sentry::TestHelper)

  config.after :each do
    reset_sentry_globals!
  end
end

def perform_basic_setup
  Sentry.init do |config|
    config.dsn = DUMMY_DSN
    config.sdk_logger = ::Logger.new(nil)
    config.background_worker_threads = 0
    config.transport.transport_class = Sentry::DummyTransport
    yield(config) if block_given?
  end
end
