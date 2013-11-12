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
    sleep 2 # who to follow popup will occassionally trigger mutation

    # tweet filtered
    lambda do
      filtered_text = "josephk92264943's tweet has been filtered. Show?"

      assert_text(filtered_text, find('.tweet'))
      click_show_tweet
      assert_text_include('dog dog', find('.tweet'))

      # make new tweet
      click('#global-new-tweet-button')
      has_css?('#tweet-box-global', visible: true)
      page.execute_script("jQuery('#tweet-box-global').text('hello')")
      click('.tweet-action')
      wait_until { first('.tweet').text == filtered_text }
    end.()

    click_show_tweet
    first('.js-action-del').click
    click('.delete-action')
    wait_until { all('.tweet').size == 1 }

    # change pages and test that click handler still works
    send_keyboard_shortcut('gp')
    wait_until { current_path == "/#{@twitter_user[:screen_name]}" }
    send_keyboard_shortcut('gh')
    wait_until { current_path == '/' }
    click_show_tweet
    assert_text_include('dog dog', find('.tweet'))

    visit_options_page
    click('.hide-completely')
    assert_settings_saved_alert

    visit('http://twitter.com')
    assert_has_no_css('.tweet')
  end
end