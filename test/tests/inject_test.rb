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
    wait_until { get_js("$($('.tweet:visible')[0]).text()").include?('reply4') }
  end

  def test
    visit_options_page
    add_filtered_phrase('reply4')
    login_twitter(@twitter_user[:screen_name], @twitter_user[:password])
    visit_twitter_and_remove_promoted
    assert_first_tweet_filtered

    visit_options_page
    remove_all_filters
    add_filtered_user(@twitter_user[:screen_name])
    visit_twitter_and_remove_promoted
    sleep 2 # the suggested users popup will trigger mutation event

    # tweet filtered
    assert_first_tweet_filtered
    click_show_tweet
    assert_tweet_not_filtered

    # mutation observer will run filter on simple tweets
    send_keyboard_shortcut('gp')
    all('.tweet')[1].click
    assert_has_css('.simple-tweet .tf-el')
    send_keyboard_shortcut('gh')

    # mutation observer will filter expanded conversations
    click('.missing-tweets-bar')
    sleep 0.5
    all('.tweet').each_with_index do |tweet, i|
      next if i == 0
      assert_text_include('filtered', tweet)
    end

    # make new tweet
    click_show_tweet
    click('#global-new-tweet-button')
    has_css?('#tweet-box-global', visible: true)
    page.execute_script("jQuery('#tweet-box-global').text('zzzzz')")
    click('.tweet-action')
    assert_first_tweet_filtered

    click_show_tweet
    first('.js-action-del').click
    click('.delete-action')
    assert_tweet_not_filtered

    # test that mentions and interactions page don't get filter applied
    send_keyboard_shortcut('gc')
    assert_has_no_css('.tf-el')
    wait_for_new_url(all('.list-link').last)
    assert_has_no_css('.tf-el')

    send_keyboard_shortcut('gh')
    # test that click handler still works after page change
    sleep 1
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

    # test hide mentions
    visit_options_page
    clear_filtered_users
    add_filtered_user('garfield')
    click('.hide-mentions-input')

    visit("https://twitter.com/#{@twitter_user[:screen_name]}")
    filtered_tweet = first('.tweet')
    assert_text_include('filtered', filtered_tweet)

    filtered_tweet.find('a').click
    assert_text_include('@garfield', filtered_tweet)

    # test hide completely
    visit_options_page
    clear_filtered_users
    add_filtered_user(@twitter_user[:screen_name])
    click('.hide-completely-input')
    assert_settings_saved_alert

    visit_twitter_and_remove_promoted
    tweet_classes = %w(.tweet .conversation-module .missing-tweets-bar .conversation-header)
    tweet_classes.each do |selector|
      assert_has_no_css(selector)
    end

    visit_options_page
    click('.enable-input')
    visit_twitter_and_remove_promoted
    assert_has_no_css('.tf-el')

    tweet_classes.each do |selector|
      assert_has_css(selector)
    end
  end
end