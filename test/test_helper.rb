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

  def set_input_and_press_enter(el, val)
    el.set(val)
    el.native.send_keys(:return)
  end

  def send_keyboard_shortcut(shortcut)
    find('body').native.send_keys(shortcut)
  end

  def login_twitter(username_or_email, password)
    visit('http://worldofrandom.org/tweets')
    wait_for_new_url(find('#twitterLogin'))

    find('#username_or_email').set(username_or_email)
    find('#password').set(password)
    wait_for_new_url(find('#allow'))
  end

  def teardown
    Capybara.reset_sessions!
  end
end