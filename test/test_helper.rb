require 'wist'
require 'capybara'
require 'pry'
require "minitest/autorun"

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app,
    browser: :chrome,
    switches: ["--load-extension=#{Dir.pwd}"]
  )
end

class CapybaraTestCase < MiniTest::Unit::TestCase
  include Capybara::DSL
  include Wist

  def setup
    Capybara.current_driver = :chrome
  end

  def teardown
    Capybara.reset_sessions!
  end
end