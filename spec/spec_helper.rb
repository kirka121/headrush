# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|

  config.include Rails.application.routes.url_helpers
  config.include Capybara::DSL

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # database_cleaner below
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Insist on 'expect' syntax rather than 'should'
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    # First, in case the database contains data from a previous run (e.g.
    # from a run that crashed), run a full clean using the truncation
    # strategy.
    DatabaseCleaner.clean_with(:truncation)

    # *** The following is specific to this project
    #     Here we set up the default tenant to be used in each test


    # *** End of project-specific portion
  end

  config.before(:each) do |example|
    # If the test is a Javascript test, set the strategy to truncation
    # as transactional cleaning will not work due to the test runner
    # and app not sharing the same process when testing from a browser.
    # For non-Javascript tests use the transaction strategy as it is faster.
    if example.metadata[:js]
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end

    DatabaseCleaner.start
  end

  config.after(:each) do |group|
    DatabaseCleaner.clean
  end

  # Load FactoryGirl helpers
  config.include FactoryGirl::Syntax::Methods
end

# Explicitly set the test server process to a particular port
# so that we can access it directly at will.
Capybara.server_port = 10000

# To ensure that browser tests can find the test server process,
# always include the port number in URLs.
Capybara.always_include_port = true

# For all tests except Javascript tests we will use :rack_test
# (the default) as it is the fastest. For Javascript tests we will
# use Selenium as it is the most robust/mature browser driver
# available.
Capybara.javascript_driver = :selenium