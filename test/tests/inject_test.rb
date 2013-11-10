require 'test_helper'

class InjectTest < CapybaraTestCase
  def setup
    super

    @twitter_user = {
      screen_name: 'josephk92264943',
      password: 'XLXIFtWB',
    }
  end

  def click_show_tweet(idx: 0)
    all_with_wait('.hidden-message')[idx].find('a').click
  end

  def test
    visit_options_page
    # empty usernames don't get added
    add_filtered_user(@twitter_user[:screen_name])

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