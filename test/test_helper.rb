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

Capybara.default_wait_time = 5

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

  def assert_settings_saved_alert
    assert_text_include('saved', find('.alert-success'))
  end

  def add_filtered_user(name)
    set_input_and_press_enter(find('.filtered-users-input'), name)
  end

  def add_filtered_phrase(phrase)
    set_input_and_press_enter(find('.filtered-phrases-input'), phrase)
  end

  def confirm_accept(expected_msg = false)
    assert_equal(expected_msg, page.driver.browser.switch_to.alert.text)
    page.driver.browser.switch_to.alert.accept
  end

  def remove_all_filters
    all('.close').each(&:click)
  end

  def set_input_and_press_enter(el, val)
    el.set(val)
    el.native.send_keys(:return)
  end

  def visit_twitter_and_remove_promoted
    visit('http://twitter.com')
    page.execute_script("jQuery('.promoted-tweet').remove()")
  end

  def send_keyboard_shortcut(shortcut)
    old_path = current_path
    find('body').native.send_keys(shortcut)
    wait_until { current_path != old_path }
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