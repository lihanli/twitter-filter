require 'test_helper'

class OptionsTest < CapybaraTestCase
  def setup
    super

    @twitter_user = {
      screen_name: 'josephk92264943',
      password: 'XLXIFtWB',
    }
  end

  def click_show_tweet(idx: 0)
    all('.hidden-message')[idx].find('a').click
  end

  def add_user(name)
    set_input_and_press_enter(find('.filtered-user-input'), name)
  end

  def user_count
    all('.filtered-users li').size
  end

  def test
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

    # empty usernames don't get added
    add_user(' <> ')
    assert_equal(0, user_count)
    add_user(' @dog ')
    # input cleared after successful input
    assert_equal('', get_val('.filtered-user-input'))
    # whitespace gets trimmed
    assert_text('@dog', find('.screen-name'))
    # test close button
    click('.filtered-users .close')
    assert_equal(0, user_count)

    return
    set_input_and_press_enter(find('.filtered-user-input'), @twitter_user[:screen_name])

    login_twitter(@twitter_user[:screen_name], @twitter_user[:password])
    visit('http://twitter.com')

    assert_text("josephk92264943's tweet has been filtered. Show?", find('.tweet'))
    click_show_tweet
    assert_text_include('dog dog', find('.tweet'))

    send_keyboard_shortcut('gp')
    wait_until { current_path == "/#{@twitter_user[:screen_name]}" }
    send_keyboard_shortcut('gh')
    wait_until { current_path == '/' }
    click_show_tweet
    assert_text_include('dog dog', find('.tweet'))
  end
end