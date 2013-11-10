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

  def visit_options_page
    visit('chrome://extensions-frame/')
    all('.options-link').last.click

    lambda do
      # get the url from new tab
      url = nil
      switch_to_window_and_execute do
        url = current_url
      end
      visit(url)
    end.()

    refresh # have to refresh or chrome apis dont work??
  end

  def clear_filtered_users
    all('.filtered-users .close').each(&:click)
  end

  def add_filtered_user(name)
    set_input_and_press_enter(find('.filtered-user-input'), name)
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