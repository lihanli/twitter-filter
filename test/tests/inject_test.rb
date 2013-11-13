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

  def assert_first_tweet_filtered
    wait_until { first('.tweet').text == "#{@twitter_user[:screen_name]}'s tweet has been filtered. Show?" }
  end

  def assert_tweet_not_filtered
    wait_until { first('.tweet').text.include?('dog dog') }
  end

  def test
    visit_options_page
    add_filtered_user(@twitter_user[:screen_name])

    login_twitter(@twitter_user[:screen_name], @twitter_user[:password])
    visit('http://twitter.com')
    sleep 2 # who to follow popup will occassionally trigger mutation

    # tweet filtered
    assert_first_tweet_filtered
    click_show_tweet
    assert_tweet_not_filtered

    # make new tweet
    original_tweet_count = all('.tweet').size
    click('#global-new-tweet-button')
    has_css?('#tweet-box-global', visible: true)
    page.execute_script("jQuery('#tweet-box-global').text('hello')")
    click('.tweet-action')
    assert_first_tweet_filtered

    click_show_tweet
    first('.js-action-del').click
    click('.delete-action')
    wait_until { all('.tweet').size == original_tweet_count }

    # test that mentions and interactions page don't get filter applied
    send_keyboard_shortcut('gc')
    assert_has_no_css('.tf-el')
    wait_for_new_url(all('.list-link').last)
    assert_has_no_css('.tf-el')

    send_keyboard_shortcut('gh')
    wait_until { current_path == '/' }
    # test that click handler still works after page change
    click_show_tweet
    assert_tweet_not_filtered

    lambda do
      toggle_hide_el = find('.toggle-hide')

      assert_text('Unhide', toggle_hide_el)
      toggle_hide_el.click
      assert_text('Hide', toggle_hide_el)

      toggle_hide_el.click
      confirm_accept("Hide all of #{@twitter_user[:screen_name]}'s tweets? This won't unfollow or block him/her.")
      assert_first_tweet_filtered
    end.()

    # test hide completely
    visit_options_page
    click('.hide-completely')
    assert_settings_saved_alert

    visit('http://twitter.com')
    %w(.tweet .conversation-module .missing-tweets-bar .conversation-header).each do |selector|
      assert_has_no_css(selector)
    end
  end
end